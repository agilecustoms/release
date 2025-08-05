## Publish in AWS

1. Pick an AWS account for publishing artifacts, place it in org variable `AWS_ACCOUNT_DIST`
2. Create S3 bucket to publish raw artifacts, ECR repository for Docker images, CodeArtifact for software packages
3. Create an IAM role (ex. `ci/publisher`) with respective permissions: `s3:PutObject`, `ecr:PutImage`, `codeartifact:PublishPackageVersion` etc.
   See example terraform module [terraform-aws-ci-publisher](https://github.com/agilecustoms/terraform-aws-ci-publisher)
