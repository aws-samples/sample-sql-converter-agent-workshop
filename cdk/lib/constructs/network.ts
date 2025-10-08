import {
  CfnInstanceConnectEndpoint,
  Port,
  SecurityGroup,
  SubnetType,
  Vpc,
} from 'aws-cdk-lib/aws-ec2';
import { Construct } from 'constructs';

export interface NetworkProps {}

export class Network extends Construct {
  readonly vpc: Vpc;
  readonly sgIceInstances: SecurityGroup;

  constructor(scope: Construct, id: string, props: NetworkProps) {
    super(scope, id);

    // VPC (1 public subnet and 1 private subnet)
    const vpc = new Vpc(this, 'Vpc', {
      maxAzs: 2,
      natGateways: 0,
      subnetConfiguration: [
        {
          cidrMask: 24,
          name: 'public',
          subnetType: SubnetType.PUBLIC,
        },
        {
          cidrMask: 24,
          name: 'private',
          subnetType: SubnetType.PRIVATE_ISOLATED,
        },
      ],
    });

    // Security Group
    const sgIce = new SecurityGroup(this, 'SgIce', {
      vpc: vpc,
    });
    const sgInstances = new SecurityGroup(this, 'SgInstances', {
      vpc: vpc,
    });
    sgIce.connections.allowTo(
      sgInstances,
      Port.tcp(22),
      'Allow SSH access from EC2 Instance Connect Endpoint'
    );

    // EC2 Instance Connect Endpoint for secure connection to EC2 instances in private subnet
    const ice = new CfnInstanceConnectEndpoint(
      this,
      'InstanceConnectEndpoint',
      {
        subnetId: vpc.isolatedSubnets[0].subnetId,
        preserveClientIp: false,
        securityGroupIds: [sgIce.securityGroupId],
      }
    );

    this.vpc = vpc;
    this.sgIceInstances = sgInstances;
  }
}
