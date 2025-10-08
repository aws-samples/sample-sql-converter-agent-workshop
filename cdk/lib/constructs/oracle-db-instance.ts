import { Duration, Fn, RemovalPolicy, Stack } from 'aws-cdk-lib';
import {
  BlockDeviceVolume,
  CfnKeyPair,
  EbsDeviceVolumeType,
  Instance,
  InstanceClass,
  InstanceSize,
  InstanceType,
  KeyPair,
  MachineImage,
  SecurityGroup,
  SubnetType,
  UserData,
  Vpc,
} from 'aws-cdk-lib/aws-ec2';
import { ManagedPolicy, Role, ServicePrincipal } from 'aws-cdk-lib/aws-iam';
import {
  BlockPublicAccess,
  Bucket,
  BucketEncryption,
} from 'aws-cdk-lib/aws-s3';
import { BucketDeployment, Source } from 'aws-cdk-lib/aws-s3-deployment';
import { Secret } from 'aws-cdk-lib/aws-secretsmanager';
import { Construct } from 'constructs';
import path = require('path');

export interface OracleDbInstanceProps {
  vpc: Vpc;
  sgIceInsntaces: SecurityGroup;
}

export class OracleDbInstance extends Construct {
  readonly oracleCredentials: Secret;
  readonly oracleSecurityGroup: SecurityGroup;
  readonly oracleInstance: Instance;

  readonly outputs: {
    ScriptBucketName: string;
    OracleInstancePublicIP: string;
    OracleInstanceId: string;
    OracleKeyPairRetrievalCommand: string;
    SSHCommand: string;
  };

  constructor(scope: Construct, id: string, props: OracleDbInstanceProps) {
    super(scope, id);

    // Create credentials for the database
    const oracleCredentials = new Secret(this, 'OracleCredentials', {
      secretName: 'oracle-credentials',
      generateSecretString: {
        secretStringTemplate: JSON.stringify({ username: 'system' }),
        excludePunctuation: true,
        includeSpace: false,
        generateStringKey: 'password',
        passwordLength: 12,
      },
      removalPolicy: RemovalPolicy.DESTROY,
    });

    // Create a security group for the Oracle EC2 instance
    const oracleSecurityGroup = new SecurityGroup(this, 'OracleSecurityGroup', {
      vpc: props.vpc,
      description: 'Security group for Oracle XE EC2 instance',
      allowAllOutbound: true,
    });

    // Create a key pair for SSH access
    const keyPair = new CfnKeyPair(this, 'OracleKeyPair', {
      keyName: 'oracle-xe-key-pair',
    });
    // Set deletion policy to delete the key pair when the stack is deleted
    keyPair.applyRemovalPolicy(RemovalPolicy.DESTROY);

    // Create an S3 bucket to store the Oracle installation script
    const scriptBucket = new Bucket(this, 'OracleScriptBucket', {
      removalPolicy: RemovalPolicy.DESTROY,
      autoDeleteObjects: true,
      blockPublicAccess: BlockPublicAccess.BLOCK_ALL,
      encryption: BucketEncryption.S3_MANAGED,
      enforceSSL: true,
      serverAccessLogsPrefix: 'AccessLogs/',
    });

    // Deploy the Oracle installation script to the S3 bucket
    const scriptDeployment = new BucketDeployment(this, 'DeployOracleScript', {
      sources: [Source.asset(path.join(__dirname, './../../scripts'))],
      destinationBucket: scriptBucket,
    });

    // Create a role for the instance to allow SSM access and S3 access
    const instanceRole = new Role(this, 'OracleInstanceRole', {
      assumedBy: new ServicePrincipal('ec2.amazonaws.com'),
      managedPolicies: [
        ManagedPolicy.fromAwsManagedPolicyName('AmazonSSMManagedInstanceCore'),
      ],
    });

    // Add S3 read permissions to the instance role
    scriptBucket.grantRead(instanceRole);
    oracleCredentials.grantRead(instanceRole);

    // Oracle XE installation user data script - simplified to download and run the script from S3
    const userDataScript = UserData.forLinux();
    userDataScript.addCommands(
      '#!/bin/bash',
      'set -e',
      'echo Oracle install work フォルダの作成',
      'mkdir -p /opt/oracle-install/',
      'echo asset ダウンロード',
      `aws s3 sync s3://${scriptBucket.bucketName}/ /opt/oracle-install/`,
      'chmod +x /opt/oracle-install/install-oracle-xe.sh'
      // user data 内でインストールスクリプトを流すとなぜか再起動が発生して途中で止まるので別途 run command で実行
      // '/opt/oracle-install/install-oracle-xe.sh'
    );

    // Create the EC2 instance with Oracle XE
    const oracleInstance = new Instance(this, 'OracleXEInstance', {
      vpc: props.vpc,
      instanceType: InstanceType.of(InstanceClass.T3, InstanceSize.LARGE), // Larger instance type for Oracle
      machineImage: MachineImage.lookup({
        name: 'al2023-ami-2023.*-kernel-6.1-x86_64',
        owners: ['amazon'],
      }),
      securityGroup: oracleSecurityGroup,
      keyPair: KeyPair.fromKeyPairName(
        this,
        'ImportedKeyPair',
        keyPair.keyName
      ),
      userData: userDataScript,
      role: instanceRole,
      vpcSubnets: {
        subnetType: SubnetType.PUBLIC,
      },
      detailedMonitoring: true,
      // Increase root volume size to accommodate Oracle XE
      blockDevices: [
        {
          deviceName: '/dev/xvda',
          volume: BlockDeviceVolume.ebs(49, {
            // 50GB root volume
            volumeType: EbsDeviceVolumeType.GP3,
            deleteOnTermination: true,
            encrypted: true,
          }),
        },
      ],
    });
    oracleInstance.node.addDependency(scriptDeployment);

    oracleInstance.addSecurityGroup(props.sgIceInsntaces);

    this.outputs = {
      ScriptBucketName: scriptBucket.bucketName,
      OracleInstancePublicIP: oracleInstance.instancePublicIp,
      OracleInstanceId: oracleInstance.instanceId,
      OracleKeyPairRetrievalCommand: Fn.join('', [
        'aws ssm get-parameter --name /ec2/keypair/',
        keyPair.attrKeyPairId,
        ' --region ',
        Stack.of(this).region,
        ' --with-decryption --query Parameter.Value --output text > oracle-xe-key.pem && chmod 400 oracle-xe-key.pem',
      ]),
      SSHCommand: Fn.join('', [
        'ssh -i oracle-xe-key.pem ec2-user@',
        oracleInstance.instancePublicIp,
      ]),
    };

    this.oracleCredentials = oracleCredentials;
    this.oracleSecurityGroup = oracleSecurityGroup;
    this.oracleInstance = oracleInstance;
  }
}
