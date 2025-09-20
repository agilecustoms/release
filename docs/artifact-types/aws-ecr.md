# publish in AWS ECR

_Note: all examples use shared patterns: two workflows: Build and Release — covered in [Best practices](../best-practices.md);
"release" GitHub environment and AWS IAM authorization — covered in [Authorization and security](../authorization.md)_

- [AWS Lambda running Spring Boot application in Docker](#aws-lambda-running-spring-boot-application-in-docker)
  - [Workflow reuse](#workflow-reuse)
  - [Application code and IaC](#application-code-and-iac)
  - [explicit version](#explicit-version)
  - [setup-maven-codeartifact](#setup-maven-codeartifact)
- [dev-release](#dev-release)

## AWS Lambda running Spring Boot application in Docker

Example: [env-cleanup](../examples/env-cleanup) — it is from AgileCustoms repository with all code removed, only workflows left

```
<repo root>
├── .github/
├── infrastructure/
├── src/             <-- java source code
├── target/          <-- fat jar created in Build workflow
├── Dockerfile
└── pom.xml          <-- maven project
```

Java and Spring Boot in this example can be replaced with any other language and framework

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

      - name: Docker build
        run: docker build -t env-cleanup:latest

      - name: Release
        uses: agilecustoms/release@v1
        with:
          aws-account: ${{ vars.AWS_ACCOUNT_DIST }}
          aws-region: us-east-1
          aws-role: 'ci/publisher'
          aws-ecr: true
```

This project also showcases a workflow reuse for different triggers, more below

When developer merges a PR, the `release-main.yml` workflow is triggered:
1. `release-main.yml` workflow calls `release.yml` workflow
2. `release.yml` workflow calls `build.yml` workflow
3. `build.yml` workflow:
   1. call `agilecustoms/setup-maven-codeartifact` to authorize maven to use dependencies from corporate `CodeArtifact` package registry
   2. run maven build (maven plugins configured to build fat jar)
   3. upload a binary (jar) as an artifact so that next workflow can access it
4. Release workflow takes over. It:
   1. download the artifact from build workflow
   2. build Docker image with the jar inside. Note: `docker build` in _Release_ workflow is not idiomatic, but it has to be in the same job that runs `docker push`
   3. call `agilecustoms/release` action
5. `agilecustoms/release` action:
   1. generate next version based on commit messages
   2. authorize in AWS ECR with role `ci/publisher`, see [Authorization and security](../authorization.md)
   3. update version in `pom.xml`
   4. push Docker image to AWS ECR with tags: `1.2.3`, `1.2`, `1` and `latest`
   5. push git commit and tags to the remote repository

### Workflow reuse

This project also showcases a workflow reuse when you want to have [dev-releases](../features/dev-release.md)
or use [explicit version](../features/version-generation.md#explicit-version).
For this purpose common release steps are placed in `release.yml` workflow file which is then called
from three specific workflows:
- `release-main.yml` — normal release on push in `main` branch
- `release-dev.yml` — [dev-releases](../features/dev-release.md) from feature branch
- `release-manual.yml` — manual release with [explicit version](../features/version-generation.md#explicit-version).

Note that `environment` is passed as input. `release-main.yml` and `release-manual.yml` use `environment: release`
meaning take `GH_TOKEN` secret from `release` environment, while `release-dev.yml` doesn't pass any environment
because dev-release doesn't push any changes/tags to remote repository. If you attempt to pass `environment: release`
in `release-dev.yml` workflow and run it from a feature branch — GitHub will show an error

### Application code and IaC

This is an example of a microservice that consists of an application (java in Docker) code and IaC (Terraform in `infrastructure` directory).
Upon release the `agilecustoms/release` generates a new version, and it is used as git tag and ECR tag.
So your code and infrastructure are in sync! Now you can deploy infra and code like this:

```hcl
module "env_cleanup" {
  source = "git::https://github.com/agilecustoms/env-cleanup.git//infrastructure?ref=1.2.3"
  aVersion = "1.2.3"
}
```

Note file `infrastructure/vars.tf` has variable `aVersion` which is used in `infrastructure/lambda.tf` to set ECR image URL

### explicit version

This example showcases how to use [explicit version](../features/version-generation.md#explicit-version).
Same as for normal release — you run `agilecustoms/release` action with input `version` on protected branch
and use GitHub environment `release` to access `GH_TOKEN` secret.
In this mode the configuration in `.releaserc.json` is ignored,
so if you need to configure a [release channel](../features/floating-tags.md#release-channel-configuration)
— use `release-channel` input instead

### setup-maven-codeartifact

`agilecustoms/release` allows to publish java packages in CodeArtifact, see [aws-codeartifact-maven](./aws-codeartifact-maven.md).
This example also shows how to _USE_ java packages published in corporate AWS CodeArtifact registry.
This is done by another GitHub action [setup-maven-codeartifact](https://github.com/agilecustoms/setup-maven-codeartifact),
see [build.yml](../examples/env-cleanup/.github/workflows/build.yml) workflow file:

```yaml
- name: Setup Java
  uses: agilecustoms/setup-maven-codeartifact@v1
  with:
    aws-account: 123456789012
    aws-region: 'us-east-1'
    aws-role: 'ci/builder'
    aws-codeartifact-domain: agilecustoms
    java-version: '23'
    java-distribution: 'corretto'
```

It also uses OIDC to assume IAM role and access CodeArtifact in read-only mode with role `ci/builder`

## dev-release

ECR supports [dev-release](../features/dev-release.md): Docker image gets published with tag equal to branch name
(branch name `feature/login` becomes ECR tag `feature-login`).
`agilecustoms/release` action enforces branch name prefix (configured via `dev-branch-prefix`, default is `feature/`).
On the other hand, the ECR supports lifecycle rules by tag prefix.
So if you apply both — you can be sure that all self-service artifacts are removed automatically in a few days!

There is one important gotcha: you can't re-run dev-release for immutable ECR repo:
- immutable ECR repo prevents pushing image for an existing tag
- tag can be deleted, but IAM doesn't allow to configure permissions selectively for tag prefix,
  so if you allow deleting tags — it is a risk that a developer can remove some non-dev tag
- if you make ECR repo mutable — it is a risk that a developer can override a non-dev tag

So if you need to re-run dev-release shortly (before old tag expired), the workaround is just to create a new branch:
`feature/login` -> `feature/login-2` and run dev-release from it
