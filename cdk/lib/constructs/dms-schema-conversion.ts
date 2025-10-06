import { CfnOutput, RemovalPolicy, ScopedAws } from 'aws-cdk-lib';
import {
  CfnDataProvider,
  CfnInstanceProfile,
  CfnMigrationProject,
  CfnReplicationSubnetGroup,
} from 'aws-cdk-lib/aws-dms';
import { Instance, Port, SecurityGroup, Vpc } from 'aws-cdk-lib/aws-ec2';
import {
  Effect,
  ManagedPolicy,
  PolicyDocument,
  PolicyStatement,
  Role,
  ServicePrincipal,
} from 'aws-cdk-lib/aws-iam';
import { DatabaseCluster } from 'aws-cdk-lib/aws-rds';
import {
  BlockPublicAccess,
  Bucket,
  BucketEncryption,
} from 'aws-cdk-lib/aws-s3';
import { Secret } from 'aws-cdk-lib/aws-secretsmanager';
import { Construct } from 'constructs';

export interface DmsSchemaConversionProps {
  vpc: Vpc;
  oracleCredentials: Secret;
  auroraPgCredentials: Secret;
  oracleSecurityGroup: SecurityGroup;
  dbCluster: DatabaseCluster;
  oracleInstance: Instance;
}

export class DmsSchemaConversion extends Construct {
  constructor(scope: Construct, id: string, props: DmsSchemaConversionProps) {
    super(scope, id);

    const { accountId, region } = new ScopedAws(this);

    // ========================================
    // DMS Schema Conversion Setup
    // ========================================

    // Create S3 bucket for DMS Schema Conversion results
    const dmsSchemaConversionBucket = new Bucket(
      this,
      'DMSSchemaConversionBucket',
      {
        bucketName: `dms-schema-conversion-${accountId}-${region}`,
        encryption: BucketEncryption.S3_MANAGED,
        blockPublicAccess: BlockPublicAccess.BLOCK_ALL,
        removalPolicy: RemovalPolicy.DESTROY, // For development environment
        autoDeleteObjects: true,
        enforceSSL: true,
        versioned: true, // Enable versioning for DMS Schema Conversion
      }
    );

    // Create IAM role for DMS Schema Conversion
    const dmsSchemaConversionRole = new Role(this, 'DMSSchemaConversionRole', {
      assumedBy: new ServicePrincipal('dms.amazonaws.com'),
      managedPolicies: [
        ManagedPolicy.fromAwsManagedPolicyName(
          'service-role/AmazonDMSCloudWatchLogsRole'
        ),
      ],
      inlinePolicies: {
        S3Access: new PolicyDocument({
          statements: [
            new PolicyStatement({
              effect: Effect.ALLOW,
              actions: [
                's3:GetObject',
                's3:GetObjectVersion',
                's3:PutObject',
                's3:DeleteObject',
                's3:ListBucket',
                's3:GetBucketLocation',
                's3:GetBucketVersioning',
              ],
              resources: [
                dmsSchemaConversionBucket.bucketArn,
                `${dmsSchemaConversionBucket.bucketArn}/*`,
              ],
            }),
          ],
        }),
        SecretsManagerAccess: new PolicyDocument({
          statements: [
            new PolicyStatement({
              effect: Effect.ALLOW,
              actions: [
                'secretsmanager:GetSecretValue',
                'secretsmanager:DescribeSecret',
              ],
              resources: [
                props.oracleCredentials.secretArn,
                props.auroraPgCredentials.secretArn,
              ],
            }),
          ],
        }),
        DMSSchemaConversionAccess: new PolicyDocument({
          statements: [
            new PolicyStatement({
              effect: Effect.ALLOW,
              actions: [
                'dms:DescribeDataProviders',
                'dms:DescribeMigrationProjects',
                'dms:DescribeInstanceProfiles',
                'dms:StartMigrationAssessment',
                'dms:DescribeMigrationAssessments',
              ],
              resources: ['*'],
            }),
          ],
        }),
      },
    });

    // Create DMS Subnet Group for Schema Conversion
    const dmsSubnetGroup = new CfnReplicationSubnetGroup(
      this,
      'DMSSubnetGroup',
      {
        replicationSubnetGroupIdentifier: 'dms-schema-conversion-subnet-group',
        replicationSubnetGroupDescription:
          'Subnet group for DMS Schema Conversion',
        subnetIds: props.vpc.publicSubnets.map((subnet) => subnet.subnetId),
        tags: [
          {
            key: 'Name',
            value: 'DMS Schema Conversion Subnet Group',
          },
        ],
      }
    );

    // Create Security Group for DMS Instance Profile
    const sg = new SecurityGroup(this, 'DMSInstanceProfileSecurityGroup', {
      vpc: props.vpc,
      description: 'Security group for DMS Instance Profile',
      allowAllOutbound: true,
    });
    props.oracleSecurityGroup.connections.allowFrom(sg, Port.tcp(1521));
    props.dbCluster.connections.allowFrom(sg, Port.POSTGRES);

    // Create DMS Instance Profile
    const dmsInstanceProfile = new CfnInstanceProfile(
      this,
      'DMSInstanceProfile',
      {
        instanceProfileName: 'ora2pg-schema-conversion-profile-cdk',
        description:
          'Instance profile for Oracle to PostgreSQL schema conversion (CDK managed)',
        networkType: 'IPV4',
        subnetGroupIdentifier: dmsSubnetGroup.replicationSubnetGroupIdentifier,
        vpcSecurityGroups: [sg.securityGroupId],
      }
    );

    // Ensure subnet group is created before instance profile
    dmsInstanceProfile.addDependency(dmsSubnetGroup);

    // Create Source Data Provider (Oracle) - CDK managed
    const oracleDataProvider = new CfnDataProvider(this, 'OracleDataProvider', {
      dataProviderName: 'oracle-xepdb1-source-provider-cdk',
      engine: 'oracle',
      description:
        'Oracle XE 21c XEPDB1 source database for schema conversion (CDK managed)',
      settings: {
        oracleSettings: {
          serverName: props.oracleInstance.instancePrivateIp,
          port: 1521,
          databaseName: 'XEPDB1',
          sslMode: 'none',
        },
      },
    });

    // Create Target Data Provider (PostgreSQL) - CDK managed
    const postgresqlDataProvider = new CfnDataProvider(
      this,
      'PostgreSQLDataProvider',
      {
        dataProviderName: 'aurora-postgresql-target-provider-cdk',
        engine: 'postgres',
        description:
          'Aurora PostgreSQL target database for schema conversion (CDK managed)',
        settings: {
          postgreSqlSettings: {
            serverName: props.dbCluster.clusterEndpoint.hostname,
            port: 5432,
            databaseName: 'postgres',
            sslMode: 'require',
          },
        },
      }
    );

    // Create Migration Project for Schema Conversion
    const migrationProject = new CfnMigrationProject(this, 'MigrationProject', {
      migrationProjectName: 'oracle-to-postgresql-migration-cdk',
      description:
        'Migration project for Oracle to PostgreSQL conversion with Schema Conversion Tool (CDK managed)',
      instanceProfileIdentifier: dmsInstanceProfile.attrInstanceProfileArn,
      sourceDataProviderDescriptors: [
        {
          dataProviderIdentifier: oracleDataProvider.attrDataProviderArn,
          secretsManagerSecretId: props.oracleCredentials.secretArn,
          secretsManagerAccessRoleArn: dmsSchemaConversionRole.roleArn,
        },
      ],
      targetDataProviderDescriptors: [
        {
          dataProviderIdentifier: postgresqlDataProvider.attrDataProviderArn,
          secretsManagerSecretId: props.auroraPgCredentials.secretArn,
          secretsManagerAccessRoleArn: dmsSchemaConversionRole.roleArn,
        },
      ],
      schemaConversionApplicationAttributes: {
        s3BucketPath: `s3://${dmsSchemaConversionBucket.bucketName}/schema-conversion-results`,
        s3BucketRoleArn: dmsSchemaConversionRole.roleArn,
      },
    });

    // Ensure dependencies are created in the correct order
    migrationProject.addDependency(dmsInstanceProfile);
    migrationProject.addDependency(oracleDataProvider);
    migrationProject.addDependency(postgresqlDataProvider);

    // ========================================
    // DMS Schema Conversion Outputs
    // ========================================

    // Output DMS Schema Conversion bucket name
    new CfnOutput(this, 'DMSSchemaConversionBucketName', {
      value: dmsSchemaConversionBucket.bucketName,
      description: 'S3 bucket for DMS Schema Conversion results and reports',
    });

    // Output Migration Project ARN
    new CfnOutput(this, 'MigrationProjectArn', {
      value: migrationProject.attrMigrationProjectArn,
      description: 'ARN of the DMS Migration Project for schema conversion',
    });

    // Output Migration Project Name
    new CfnOutput(this, 'MigrationProjectName', {
      value: migrationProject.migrationProjectName!,
      description: 'Name of the DMS Migration Project',
    });

    // Output Oracle Data Provider ARN
    new CfnOutput(this, 'OracleDataProviderArn', {
      value: oracleDataProvider.attrDataProviderArn,
      description: 'ARN of the Oracle source data provider',
    });

    // Output PostgreSQL Data Provider ARN
    new CfnOutput(this, 'PostgreSQLDataProviderArn', {
      value: postgresqlDataProvider.attrDataProviderArn,
      description: 'ARN of the PostgreSQL target data provider',
    });

    // Output DMS Instance Profile ARN
    new CfnOutput(this, 'DMSInstanceProfileArn', {
      value: dmsInstanceProfile.attrInstanceProfileArn,
      description: 'ARN of the DMS Instance Profile',
    });
  }
}
