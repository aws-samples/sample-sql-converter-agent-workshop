import { Duration, RemovalPolicy } from 'aws-cdk-lib';
import { SubnetType, Vpc } from 'aws-cdk-lib/aws-ec2';
import {
  AuroraPostgresEngineVersion,
  ClusterInstance,
  Credentials,
  DatabaseCluster,
  DatabaseClusterEngine,
} from 'aws-cdk-lib/aws-rds';
import { Secret } from 'aws-cdk-lib/aws-secretsmanager';
import { Construct } from 'constructs';

export interface AuroraServerlessPgProps {
  vpc: Vpc;
}

export class AuroraServerlessPg extends Construct {
  readonly auroraPgCredentials: Secret;
  readonly dbCluster: DatabaseCluster;

  constructor(scope: Construct, id: string, props: AuroraServerlessPgProps) {
    super(scope, id);

    // Create credentials for the database
    const auroraPgCredentials = new Secret(this, 'AuroraPgCredentials', {
      secretName: 'aurora-pg-credentials',
      generateSecretString: {
        secretStringTemplate: JSON.stringify({ username: 'postgres' }),
        excludePunctuation: true,
        includeSpace: false,
        generateStringKey: 'password',
      },
      removalPolicy: RemovalPolicy.DESTROY,
    });

    // Create the Aurora PostgreSQL Serverless v2 cluster
    const dbCluster = new DatabaseCluster(this, 'AuroraPostgreSQLCluster', {
      engine: DatabaseClusterEngine.auroraPostgres({
        version: AuroraPostgresEngineVersion.VER_15_10,
      }),
      credentials: Credentials.fromSecret(auroraPgCredentials),
      vpc: props.vpc,
      vpcSubnets: {
        subnetType: SubnetType.PRIVATE_ISOLATED,
      },
      serverlessV2MinCapacity: 0.5, // Minimum ACU (Aurora Capacity Units)
      serverlessV2MaxCapacity: 1, // Maximum ACU - keeping it low for cost efficiency
      writer: ClusterInstance.serverlessV2('writer'),
      storageEncrypted: true,
      deletionProtection: false,
      iamAuthentication: true,
      backup: {
        retention: Duration.days(7), // Minimum backup retention
      },
      // Data APIを有効化
      enableDataApi: true,
    });

    this.auroraPgCredentials = auroraPgCredentials;
    this.dbCluster = dbCluster;
  }
}
