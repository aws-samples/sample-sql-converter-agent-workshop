#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { Ora2pgStack } from '../lib/ora2pg-stack';
// import { AwsSolutionsChecks } from "cdk-nag";

const app = new cdk.App();
// cdk.Aspects.of(app).add(new AwsSolutionsChecks());
new Ora2pgStack(app, 'Ora2pgStack', {
  initializeDmsSc: false,
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION,
  },
});
