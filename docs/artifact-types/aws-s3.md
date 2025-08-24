# publish in AWS S3

_Note: all examples use shared patterns: two workflows: Build and Release — covered in [Best practices](../best-practices.md);
"release" GitHub environment and AWS IAM authorization — covered in [Authorization and security](../authorization.md)_

AWS S3 is very powerful, and specifically it works very well for software distribution.
S3 allows flexible read and write permissions by prefix and by tags. And it has rules for expiration so you can auto remove temporary artifacts 

For publishing in S3 the `agilecustoms/release` uses a simple convention:
if there is an `s3` directory in cwd, then all files from it will be uploaded to S3 bucket
at path `{aws-s3-bucket}/{current-repo-name}/{version}/`. Given version is `1.3.0` and `floating-tags` is `true` (default),
then files will also be uploaded to `{aws-s3-bucket}/{current-repo-name}/1/`, `{aws-s3-bucket}/{current-repo-name}/1.3/`
and `{aws-s3-bucket}/{current-repo-name}/latest/` directories, see [floating-tags](../features/floating-tags.md) for details

Additionally, you can specify `aws-s3-dir`, then files will be uploaded to `{aws-s3-bucket}/{aws-s3-dir}/{current-repo-name}/..`

In this section we'll cover some examples of releasing software artifacts in S3:
- [Python lambda function](#python-lambda-function)
  - [Application code and IaC](#application-code-and-iac)
- [Go lambda function](#go-lambda-function)
- [Static website](#static-website)
- [Java CLI application](#java-cli-application)
- [dev-release](#dev-release)

## Python lambda function

Example: [env-api](../examples/env-api) — it is from AgileCustoms repository with all code removed, only workflows left

```
<repo root>
├── .github/
├── dist/            <-- _NOT_ stored in git
│   └── app.zip      <-- created in Build workflow
├── infrastructure/  <-- terraform code
├── src/             <-- python code
└── pyproject.toml   <-- poetry configuration file
```

Here Poetry is used to manage dependencies. You can use any other tool,
main part is that in the Build workflow you create a zip file with your code and all dependencies

```yaml
jobs:
  Build:
    uses: ./.github/workflows/build.yml
    # ...

  Release:
    needs: Build
    # ...
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Download artifacts
        uses: actions/download-artifact@v4

      # this will download `app.zip` in `s3` directory (see Build workflow)
      # next step recognize that `s3` directory exists and upload all files from it to S3

      - name: Release
        uses: agilecustoms/release@v1
        with:
          aws-account: ${{ vars.AWS_ACCOUNT_DIST }}
          aws-region: us-east-1
          aws-role: 'ci/publisher'
          aws-s3-bucket: 'agilecustoms-dist'
```

When developer merges a PR, the Release workflow is triggered:
1. Release workflow calls Build workflow
2. Build workflow packages python code and dependencies in `dist/app.zip` file and uploads it as an artifact named `s3`
3. Release workflow downloads the artifact, so you get `s3/app.zip`
4. Release workflow calls `agilecustoms/release` action, then action:
   1. generate next version based on commit messages
   2. authorize in AWS with role `ci/publisher`, see [Authorization and security](../authorization.md)
   3. update version in `pyproject.toml`
   4. upload `s3/app.zip` to `agilecustoms-dist/env-api/{version}/app.zip`
   5. push git commit and tags to the remote repository

### Application code and IaC

This is an example of a microservice that consists of an application (Python) code and IaC (Terraform in `infrastructure` directory).
Upon release the `agilecustoms/release` generates a new version, and it is used as git tag and S3 prefix.
So your code and infrastructure are in sync! Now you can deploy infra and code like this:

```hcl
module "env_api" {
  source = "git::https://github.com/agilecustoms/env-api.git//infrastructure?ref=1.2.3"
  aVersion = "1.2.3"
}
```

Note file `infrastructure/vars.tf` has variable `aVersion` which is used in `infrastructure/lambda.tf` as part of `s3_key`

## Go lambda function

TBD

## Static website

TBD

## Java CLI application

TBD

## dev-release

TBD

Publish files in `{aws-s3-bucket}/{current-repo-name}/{current-branch-name}/` directory.
Each S3 file will be tagged with `Release=false`, so you can set up lifecycle rule to delete such files after 30 days!
