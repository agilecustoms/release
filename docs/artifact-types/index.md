# Use cases

- [Publish in AWS](#publish-in-aws)
  - [Publish in AWS S3](#publish-in-aws-s3)
  - [Publish in AWS ECR](#publish-in-aws-ecr)
  - [Publish in AWS CodeArtifact Maven repository](#publish-in-aws-codeartifact-maven-repository)
- [Non-AWS](#non-aws)
  - [Publish in public npmjs repo](#publish-in-public-npmjs-repo)
  - [No artifacts (git tags + GH release)](#no-artifacts-git-tags--gh-release)
  - [Release terraform module](#release-terraform-module)
  - [Release TypeScript GH Action](#release-typescript-gh-action)
- [Additional use cases](#additional-use-cases)
  - [Release from non-main branch](#release-from-non-main-branch)
  - [Explicit version](#explicit-version)

## Publish in AWS 

1. Pick an AWS account for publishing artifacts, place it in org variable `AWS_ACCOUNT_DIST`
2. Create S3 bucket to publish raw artifacts, ECR repository for Docker images, CodeArtifact for software packages
3. Create an IAM role (ex. `ci/publisher`) with respective permissions: `s3:PutObject`, `ecr:PutImage`, `codeartifact:PublishPackageVersion` etc.
   See example terraform module [terraform-aws-ci-publisher](https://github.com/agilecustoms/terraform-aws-ci-publisher)









## Non-AWS artifact stores






## Additional use cases

### release from non-main branch

Assume the main development (v2.x) is conducted in `main` branch, while version 1.x is maintained in `v1-support` branch.
If you want to make release in support branch, you need
1. run actions/checkout with with `fetch-depth: 0`
```yaml
on:
   push:
      branches:
         - v1-support
jobs:
   Release:
      runs-on: ubuntu-latest
      permissions:
         contents: write
      steps:
         - name: Checkout
           uses: actions/checkout@v4
           with:
              fetch-depth: 0

         - name: Release
           uses: agilecustoms/release@v1
```
Note: tag `latest` is only added to default (typically `main`) branch,
so if you release new "patch" version in "support" branch w/ and most recent tag is "1.2.3",
then new tag will be `1.2.4` plus tags `1`, `1.2` will be overwritten to point to the same commit as `1.2.4`, but `latest` tag will not be changed

### explicit version

Use the `version` input parameter to specify an exact version instead of auto-generating one.
When provided, only this single version/tag will be created (no `latest`, `major`, or `minor` tags).
Typically, you use normal release flow (for trunk-based development) or `dev-release: true` to test some feature before merging it.

Use explicit **version** as last resort:
1. to fix an existing version in-place
2. instead of dev-release when it is not supported
