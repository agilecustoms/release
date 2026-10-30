#!/usr/bin/env bash
# Validate inputs, infer defaults
# Inputs (env): VERSION, DEV_RELEASE, DEV_BRANCH_PREFIX, AWS_ACCOUNT, AWS_REGION, AWS_ROLE, AWS_ECR,
#  AWS_CODEARTIFACT_MAVEN, AWS_CODEARTIFACT_DOMAIN, AWS_S3_BUCKET
# Outputs: service, aws_s3 (only if s3/ directory exists)
set -eo pipefail

# Validate version: explicit version cannot be used with dev-release=true
if [ -n "$VERSION" ] && [ "$DEV_RELEASE" = "true" ]; then
  echo "Error: explicit version cannot be used with dev-release=true" >&2
  exit 1
fi
# GITHUB_REPOSITORY has a format of 'company/service'
service="${GITHUB_REPOSITORY#*/}"
echo "service=$service" >> "$GITHUB_OUTPUT"

if [ "$DEV_RELEASE" = "true" ] && [ -n "$DEV_BRANCH_PREFIX" ]; then
  branch="${GITHUB_REF#refs/heads/}"
  if [[ "$branch" != "$DEV_BRANCH_PREFIX"* ]]; then
    echo "Error: current branch '$branch' must start with '$DEV_BRANCH_PREFIX' when dev-release is true" >&2
    exit 1
  fi
fi

if [ -d s3 ]; then
  echo "aws_s3=true" >> "$GITHUB_OUTPUT"
fi

if [ -d s3 ] || [ "$AWS_ECR" = "true" ] || [ -n "$AWS_CODEARTIFACT_MAVEN" ]; then
  if [ -z "$AWS_ACCOUNT" ] || [ -z "$AWS_REGION" ] || [ -z "$AWS_ROLE" ]; then
    echo "Error: aws-account, aws-region, and aws-role must all be provided" >&2
    exit 1
  fi
fi

if [ -n "$AWS_CODEARTIFACT_MAVEN" ] && [ -z "$AWS_CODEARTIFACT_DOMAIN" ]; then
  echo "Error: aws-codeartifact-domain must be provided when aws-codeartifact-maven is set" >&2
  exit 1
fi

if [ -d s3 ] && [ -z "$AWS_S3_BUCKET" ]; then
  echo "Error: aws-s3-bucket must be provided when using S3" >&2
  exit 1
fi
