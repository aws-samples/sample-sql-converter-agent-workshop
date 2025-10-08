import {
  CfnServiceLinkedRole,
  ManagedPolicy,
  Role,
  ServicePrincipal,
} from 'aws-cdk-lib/aws-iam';
import { Construct } from 'constructs';

export interface DmsInitializationProps {}

export class DmsInitialization extends Construct {
  constructor(scope: Construct, id: string, props: DmsInitializationProps) {
    super(scope, id);

    const dmsSlr = new CfnServiceLinkedRole(this, 'DmsSlr', {
      awsServiceName: 'dms.amazonaws.com',
      description:
        'Service-linked role required by AWS Database Migration Service',
    });
    const vpcRole = new Role(this, 'DmsVpcRole', {
      roleName: 'dms-vpc-role',
      assumedBy: new ServicePrincipal('dms.amazonaws.com'),
      managedPolicies: [
        ManagedPolicy.fromAwsManagedPolicyName(
          'service-role/AmazonDMSVPCManagementRole'
        ),
      ],
    });
    const cwRole = new Role(this, 'DmsCwLogsRole', {
      roleName: 'dms-cloudwatch-logs-role',
      assumedBy: new ServicePrincipal('dms.amazonaws.com'),
      managedPolicies: [
        ManagedPolicy.fromAwsManagedPolicyName(
          'service-role/AmazonDMSCloudWatchLogsRole'
        ),
      ],
    });
  }
}
