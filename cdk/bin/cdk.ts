#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { SqlConverterStack } from '../lib/sql-converter-stack';
// import { AwsSolutionsChecks } from "cdk-nag";

const app = new cdk.App();
// cdk.Aspects.of(app).add(new AwsSolutionsChecks());
new SqlConverterStack(app, 'SqlConverterStack', {
  initializeDmsSc: true,
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION,
  },
});
