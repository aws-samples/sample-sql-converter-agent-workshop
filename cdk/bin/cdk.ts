#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { Ora2pgStack } from '../lib/ora2pg-stack';

const app = new cdk.App();
new Ora2pgStack(app, 'Ora2pgStack', {
  initializeDmsSc: true,
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION,
  },
});
