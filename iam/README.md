# AWS Identity and Access Management (IAM)

Manage access to different resources. Here we have a couple of our custom policies. See the [AWS IAM User guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html).

## CodeDeploy-EC2-Permissions

Your Amazon EC2 instances need permission to access the Amazon S3 buckets or GitHub repositories where the applications that will be deployed by AWS CodeDeploy are stored. These instructions show you how to create an IAM instance profile to attach to your Amazon EC2 instances to give this permission. (Page 118 of [CodeDeploy User guide](https://docs.aws.amazon.com/codedeploy/latest/userguide/codedeploy-user.pdf))

## Force_MFA

This policy allows users to manage their own passwords and multi-factor authentication (MFA) devices but nothing else unless they authenticate with MFA.

This policy should be applied to any group where users need to login.

## S3-Access-Production-Spirited-Media

Provides full access to all buckets via the AWS Management Console.

## S3-Access-Staging-Spirited-Media

via https://deliciousbrains.com/wp-offload-s3/doc/quick-start-guide/

## S3-spiritedmedia-com-readWriteObjects

Read-Write access for objects for the spiritedmedia-com bucket
