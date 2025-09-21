# publish in AWS CodeArtifact Maven repository

_Note: all examples use shared patterns: two workflows: Build and Release — covered in [Best practices](../best-practices.md);
"release" GitHub environment and AWS IAM authorization — covered in [Authorization and security](../authorization.md)_

## Multi-module maven project

Example: [java-parent](../examples/java-parent) - it is from AgileCustoms repository with all code removed, only workflows left

```
<repo root>
├── .github/
├── module1/
├── module2/
└── pom.xml   <-- must have <distributionManagement> section
```

This is a classic java project storing some utilities reusable across an organization.
It is a multi-module maven project.

```yaml
jobs:
  Build:
    uses: ./.github/workflows/build.yml

  Release:
    needs: Build
    # ...
    steps:
      # ...
      - name: Download artifacts
        uses: actions/download-artifact@v5

      - name: Release
        uses: agilecustoms/release@v1
        with:
          aws-account: ${{ vars.AWS_ACCOUNT_DIST }}
          aws-region: us-east-1
          aws-role: 'ci/publisher'
          aws-codeartifact-maven: true # tells action to publish in AWS CodeArtifact Maven repo
```

Besides release workflow, next infrastructure pieces must be aligned:
1. There should be an IAM role (`ci/publisher`) which can be assumed by GitHub Actions via OIDC, see [Authorization and security](../authorization.md)
2. AWS IAM role's policy should allow `codeartifact:PublishPackageVersion` and few more actions.
   You can use Terraform module [ci-publisher](https://registry.terraform.io/modules/agilecustoms/ci-publisher/aws/latest)
3. You need to have a CodeArtifact _domain_ and _repository_ created. CodeArtifact _domain_ acts as namespace for your packages,
   typically your company name. In this example _domain_ is `agilecustoms`.
   CodeArtifact _repository_ allows arbitrary name, but let's use `maven`.
4. In root `pom.xml` you need to have `<distributionManagement>` section like this:
```xml
<distributionManagement>
  <repository>
    <id>agilecustoms-maven</id>
    <url>https://${env.ARTIFACT_STORE_HOST}/maven/maven/</url>
  </repository>
</distributionManagement>
```
Here `<id>` has format `{domain}-{repository}`, so replace `agilecustoms` with your company name.

When developer merges a PR, the Release workflow is triggered:
1. Release workflow calls Build workflow
2. Build workflow compiles java code in `target/*.jar` files and uploads them as an artifact
3. Release workflow downloads the artifact and calls `agilecustoms/release` action, then action:
   1. generate next version based on commit messages
   2. call `agilecustoms/setup-maven-codeartifact`, this action:
      1. authorize in AWS CodeArtifact, see [Authorization and security](../authorization.md)
      2. generate env variable `ARTIFACT_STORE_HOST`
      3. create file `settings.xml` with credentials
   3. update version in `pom.xml` (and all submodules for multi-module projects)
   4. run `mvn deploy` to publish packages in CodeArtifact. Maven uses repository id from `pom.xml` `distributionManagement` section
      and find matching section `<server>` (with credentials) in `settings.xml` prepared by `setup-maven-codeartifact` action
   5. push git commit and tags to the remote repository

### setup-maven-codeartifact

Main intent of this example is to demonstrate how to _PUBLISH_ Maven packages in CodeArtifact.
But first an artifact needs to be built. If this maven module depends on other module(s) published in CodeArtifact,
you can use [setup-maven-codeartifact](https://github.com/agilecustoms/setup-maven-codeartifact) to access them.
See [build.yml](../examples/java-parent/.github/workflows/build.yml) workflow file:

```yaml
- name: Setup Java
  uses: agilecustoms/setup-maven-codeartifact@v1
  with:
    aws-account: 123456789012
    aws-region: 'us-east-1'
    aws-codeartifact-domain: agilecustoms
```

Here the default java version (21) and distribution (temurin) are used.
Under the hood the `aws-actions/configure-aws-credentials` is used to assume an AWS IAM role (default is `ci/builder`)
to gain read-only access to CodeArtifact to fetch dependencies
