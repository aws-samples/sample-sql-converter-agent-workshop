import { AwsCustomResource, AwsCustomResourcePolicy, PhysicalResourceId } from 'aws-cdk-lib/custom-resources';
import { Construct } from 'constructs';

export interface DmsInitializationProps {}

export class DmsInitialization extends Construct {
  constructor(scope: Construct, id: string, props: DmsInitializationProps) {
    super(scope, id);

    // Create DMS Service Linked Role
    const dmsSlr = new AwsCustomResource(this, 'DmsSlr', {
      onCreate: {
        service: 'IAM',
        action: 'createServiceLinkedRole',
        parameters: {
          AWSServiceName: 'dms.amazonaws.com',
          Description: 'Service-linked role required by AWS Database Migration Service'
        },
        ignoreErrorCodesMatching: 'InvalidInput',
        physicalResourceId: PhysicalResourceId.of('dms-service-linked-role')
      },
      policy: AwsCustomResourcePolicy.fromSdkCalls({
        resources: AwsCustomResourcePolicy.ANY_RESOURCE
      })
    });

    // Create DMS VPC Role
    const dmsVpcRole = new AwsCustomResource(this, 'DmsVpcRole', {
      onCreate: {
        service: 'IAM',
        action: 'createRole',
        parameters: {
          RoleName: 'dms-vpc-role',
          AssumeRolePolicyDocument: JSON.stringify({
            Version: '2012-10-17',
            Statement: [
              {
                Effect: 'Allow',
                Principal: { Service: 'dms.amazonaws.com' },
                Action: 'sts:AssumeRole'
              }
            ]
          }),
          Description: 'Role for DMS VPC management'
        },
        ignoreErrorCodesMatching: 'EntityAlreadyExists',
        physicalResourceId: PhysicalResourceId.of('dms-vpc-role')
      },
      policy: AwsCustomResourcePolicy.fromSdkCalls({
        resources: AwsCustomResourcePolicy.ANY_RESOURCE
      })
    });

    // Attach VPC Management Policy to DMS VPC Role
    const dmsVpcRolePolicy = new AwsCustomResource(this, 'DmsVpcRolePolicy', {
      onCreate: {
        service: 'IAM',
        action: 'attachRolePolicy',
        parameters: {
          RoleName: 'dms-vpc-role',
          PolicyArn: 'arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole'
        },
        ignoreErrorCodesMatching: 'NoSuchEntity',
        physicalResourceId: PhysicalResourceId.of('dms-vpc-role-policy')
      },
      policy: AwsCustomResourcePolicy.fromSdkCalls({
        resources: AwsCustomResourcePolicy.ANY_RESOURCE
      })
    });

    // Create DMS CloudWatch Logs Role
    const dmsCwRole = new AwsCustomResource(this, 'DmsCwLogsRole', {
      onCreate: {
        service: 'IAM',
        action: 'createRole',
        parameters: {
          RoleName: 'dms-cloudwatch-logs-role',
          AssumeRolePolicyDocument: JSON.stringify({
            Version: '2012-10-17',
            Statement: [
              {
                Effect: 'Allow',
                Principal: { Service: 'dms.amazonaws.com' },
                Action: 'sts:AssumeRole'
              }
            ]
          }),
          Description: 'Role for DMS CloudWatch Logs access'
        },
        ignoreErrorCodesMatching: 'EntityAlreadyExists',
        physicalResourceId: PhysicalResourceId.of('dms-cloudwatch-logs-role')
      },
      policy: AwsCustomResourcePolicy.fromSdkCalls({
        resources: AwsCustomResourcePolicy.ANY_RESOURCE
      })
    });

    // Attach CloudWatch Logs Policy to DMS CloudWatch Role
    const dmsCwRolePolicy = new AwsCustomResource(this, 'DmsCwLogsRolePolicy', {
      onCreate: {
        service: 'IAM',
        action: 'attachRolePolicy',
        parameters: {
          RoleName: 'dms-cloudwatch-logs-role',
          PolicyArn: 'arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole'
        },
        ignoreErrorCodesMatching: 'NoSuchEntity',
        physicalResourceId: PhysicalResourceId.of('dms-cloudwatch-logs-role-policy')
      },
      policy: AwsCustomResourcePolicy.fromSdkCalls({
        resources: AwsCustomResourcePolicy.ANY_RESOURCE
      })
    });

    // Ensure dependencies
    dmsVpcRolePolicy.node.addDependency(dmsVpcRole);
    dmsCwRolePolicy.node.addDependency(dmsCwRole);
  }
}
