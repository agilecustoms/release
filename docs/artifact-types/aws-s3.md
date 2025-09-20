# publish in AWS S3

_Note: all examples use shared patterns: two workflows: Build and Release — covered in [Best practices](../best-practices.md);
"release" GitHub environment and AWS IAM authorization — covered in [Authorization and security](../authorization.md)_

AWS S3 is very powerful, and specifically, it works very well for software distribution.
S3 allows flexible read and write permissions by prefix and by tags. And it has rules for expiration so you can auto remove temporary artifacts 

For publishing in S3 the `agilecustoms/release` uses a simple convention:
if there is an `s3` directory in cwd, then all files from it will be uploaded to S3 bucket
at path `{aws-s3-bucket}/{current-repo-name}/{version}/`. Given version is `1.3.0` and `floating-tags` is `true` (default),
then files will also be uploaded to `{aws-s3-bucket}/{current-repo-name}/1/`, `{aws-s3-bucket}/{current-repo-name}/1.3/`
and `{aws-s3-bucket}/{current-repo-name}/latest/` directories, see [floating-tags](../features/floating-tags.md) for details

Additionally, you can specify `aws-s3-dir`, then files will be uploaded to `{aws-s3-bucket}/{aws-s3-dir}/{current-repo-name}/..`

In this section we'll cover some examples of releasing software artifacts in S3:
- [Python lambda function](#python-lambda-function)
- [Static website](#static-website)
- [Go lambda function](#go-lambda-function)
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
        uses: actions/checkout@v5

      - name: Download artifacts
        uses: actions/download-artifact@v5

      # this will download `app.zip` and place it in `s3` directory (see Build workflow)
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

### IaC

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

## Static website

Example: [tt-web](../examples/tt-web) — it is from AgileCustoms repository with all code removed, only workflows left

```
<repo root>
├── .github/
├── dist/             <-- created in Build workflow
│   ├── assets/ 
│   └── index.html
├── infrastructure/   <-- terraform code
├── src/              <-- TypeScript code
└── package.json
```

In this example a standard npm is used to manage dependencies and `vite` to build static files.
Note: there is no 'package' phase like in Python. That's because AWS offers static website hosting directly from S3 bucket,
and it also offers "copy files" API available in Terraform as `aws_s3_object_copy` resource.
So the distribution format (how release files are stored) should match how S3 serves static files.

Also, this example showcases use of corporate action `mycompany/gha-release` which is a thin wrapper around `agilecustoms/release`.
In this action you provide all defaults, so your release workflow gets even simpler, see [details](../best-practices.md#company-specific-gha-release-wrapper)

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
        uses: actions/checkout@v5

      - name: Download artifacts
        uses: actions/download-artifact@v5

      # this will download static assets and place them in `s3` directory (see Build workflow)
      # next step recognize that `s3` directory exists and upload all files from it to S3

      - name: Release
        uses: mycompany/gha-release@main
        env:
          GH_TOKEN: ${{ secrets.GH_TOKEN }}
```

When developer merges a PR, the Release workflow is triggered:
1. Release workflow calls Build workflow
2. Build workflow uses `vite` to compile TypeScript in JavaScript and place final bundled code in `dist` directory, then Build workflow uploads `dist` directory as an artifact named `s3`
3. Release workflow downloads the artifact, so you get `s3/{dist content}`
4. Release workflow calls `mycompany/release-gha` action
5. `mycompany/release-gha` calls `agilecustoms/release` passing lots of defaults: `aws-account`, `aws-region`, `aws-s3-bucket` and others
6. `aguilecustoms/release` action then:
    1. generate next version based on commit messages
    2. authorize in AWS with role `ci/publisher`, see [Authorization and security](../authorization.md)
    3. update version in `package.json`
    4. upload `s3/*` to `mycompany-dist/tt-web/{version}/*`
    5. push git commit and tags to the remote repository

### IaC

This is an example of a microservice that consists of an application (TypeScript) code and IaC (Terraform in `infrastructure` directory).
Upon release the `agilecustoms/release` generates a new version, and it is used as git tag and S3 prefix.
So your code and infrastructure are in sync! Now you can deploy infra and code like this:

```hcl
module "tt_web" {
  source = "git::https://github.com/agilecustoms/tt-web.git//infrastructure?ref=1.2.3"
  aVersion = "1.2.3"
}
```

Note file `infrastructure/main.tf` has variable `aVersion` which is datasource `aws_s3_objects` to access (download) files
from dist S3 bucket and then upload them in static website using resource `aws_s3_object_copy`

## Go lambda function

TBD

## Java CLI application

TBD

## dev-release

S3 supports [dev-release](../features/dev-release.md). Branch name `feature/login` becomes a version `feature-login`,
and files uploaded at `{aws-s3-bucket}/{current-repo-name}/feature-login/`

`agilecustoms/release` action adds tag `Release` to each S3 object. In normal mode `Release=true`, in dev-release mode `Release=false`.
It is important for security and cleanup:
- you can configure S3 lifecycle rule to auto-remove objects with tag `Release=false` after 30 days
- IAM role (e.g. `ci/publisher-dev`) used in dev-release workflow can distinguish between normal release and dev-release:
  it allows to override `Release=false` objects and deny to override `Release=true`
