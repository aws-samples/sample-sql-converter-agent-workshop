import { CfnOutput, Stack, StackProps } from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { AuroraServerlessPg } from './constructs/aurora-serverless-pg';
import { DmsInitialization } from './constructs/dms-initialization';
import { DmsSchemaConversion } from './constructs/dms-schema-conversion';
import { Network } from './constructs/network';
import { OracleDbInstance } from './constructs/oracle-db-instance';

export interface SqlConverterAgentStackProps extends StackProps {
  initializeDmsSc: boolean; // true の場合、DMS SC のセットアップに必要なリソース作成を実施
}

export class SqlConverterAgentStack extends Stack {
  constructor(scope: Construct, id: string, props: SqlConverterAgentStackProps) {
    super(scope, id, props);

    // Network
    const network = new Network(this, 'Network', {});

    // Oracle DB Instance
    const oracleDb = new OracleDbInstance(this, 'OracleDbInstance', {
      vpc: network.vpc,
      sgIceInsntaces: network.sgIceInstances,
    });

    // Aurora Serverless
    const auroraPg = new AuroraServerlessPg(this, 'AuroraServerlessPg', {
      vpc: network.vpc,
    });

    // DMS SC
    const dmsSc = new DmsSchemaConversion(this, 'DmsSchemaConversion', {
      vpc: network.vpc,
      oracleCredentials: oracleDb.oracleCredentials,
      auroraPgCredentials: auroraPg.auroraPgCredentials,
      oracleSecurityGroup: oracleDb.oracleSecurityGroup,
      dbCluster: auroraPg.dbCluster,
      oracleInstance: oracleDb.oracleInstance,
    });

    // DMS SC Initialization (if necessary)
    if (props.initializeDmsSc) {
      const dmsInitialization = new DmsInitialization(
        this,
        'DmsInitialization',
        {}
      );
      dmsSc.node.addDependency(dmsInitialization);
    }

    // Outputs
    // Output the S3 Bucket Name
    new CfnOutput(this, 'ScriptBucketName', {
      exportName: 'ScriptBucketName',
      value: oracleDb.outputs.ScriptBucketName,
      description: 'ScriptBucketName',
    });

    // Output the EC2 instance public IP
    new CfnOutput(this, 'OracleInstancePublicIP', {
      exportName: 'OracleInstancePublicIP',
      value: oracleDb.outputs.OracleInstancePublicIP,
      description: 'Public IP address of the Oracle XE instance',
    });

    // Output the EC2 instance ID
    new CfnOutput(this, 'OracleInstanceId', {
      exportName: 'OracleInstanceId',
      value: oracleDb.outputs.OracleInstanceId,
      description: 'Instance ID of the Oracle XE instance',
    });

    // Output instructions to retrieve the private key using SSM Parameter Store
    new CfnOutput(this, 'OracleKeyPairRetrievalCommand', {
      exportName: 'OracleKeyPairRetrievalCommand',
      value: oracleDb.outputs.OracleKeyPairRetrievalCommand,
      description:
        'Command to retrieve and save the private key from SSM Parameter Store',
    });

    // Output SSH command
    new CfnOutput(this, 'SSHCommand', {
      exportName: 'SSHCommand',
      value: oracleDb.outputs.SSHCommand,
      description: 'SSH command to connect to the Oracle XE instance',
    });

    // Output the Aurora database endpoint
    new CfnOutput(this, 'DBEndpoint', {
      exportName: 'DBEndpoint',
      value: auroraPg.dbCluster.clusterEndpoint.hostname,
      description: 'Aurora PostgreSQL Endpoint',
    });
  }
}
