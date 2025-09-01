# About

Release software artifacts in AWS (S3, ECR, CodeArtifact) and NPM with consistent versioning!

![Cover](docs/images/cover.png)

You can release **any combination** of software packages, binary files, docker images, and raw repo files

This is especially useful in microservices where the releases are _binary_ + _IaC_ versioned via git tag

The action comes with an **ecosystem**:
- Terraform modules to provide AWS roles and policies to [read](https://registry.terraform.io/modules/agilecustoms/ci-builder/aws/latest) and [publish](https://registry.terraform.io/modules/agilecustoms/ci-publisher/aws/latest) artifacts
- GitHub actions to use in build workflows, e.g., [setup-maven-codeartifact](https://github.com/agilecustoms/setup-maven-codeartifact)
- documentation and examples for all supported [artifact types](./docs/artifact-types/index.md)
- [Authorization and Security](./docs/authorization.md) — how to make releases secure, including self-service (dev-releases)
- Release workflow [best practices](./docs/best-practices.md)
- Articles: [Software distribution in AWS](https://www.linkedin.com/pulse/software-distribution-aws-alexey-chekulaev-ubl0e)

## Features

- automatic and manual [version generation](./docs/features/version-generation.md)
- release notes generation and changelog update
- [floating tags](./docs/features/floating-tags.md) — given current version is `1.2.3` and you release `1.2.4` then also create/move tags `1.2`, `1` and `latest`
- [maintenance releases](./docs/features/maintenance-release.md) — made from branch like `1.x.x` (given `2.x.x` development is in `main`)
- [prereleases](./docs/features/prerelease.md) — develop a next (often major, sometimes minor) version, typically made from a branch `next`
- [dev-release](./docs/features/dev-release.md) — ability to publish artifacts for dev testing when testing on a local machine is impossible/complicated
- [idempotency](./docs/features/idempotency.md) — ability to re-run the action without side effects
- GitHub release

## Artifact types ⇔ features

| Artifact type                                                             | floating tags | idempotency | dev-release | auto cleanup |
|---------------------------------------------------------------------------|---------------|-------------|-------------|--------------|
| [git](./docs/artifact-types/git.md)                                       | ✅             | ✅           | ✅ ️         | ✅            |
| [AWS S3](./docs/artifact-types/aws-s3.md)                                 | ✅             | ✅           | ✅           | ✅            |
| [AWS ECR](./docs/artifact-types/aws-ecr.md)                               | ✅             | ✅           | ✅           | ✅            |
| [AWS CodeArtifact maven](./docs/artifact-types/aws-codeartifact-maven.md) | ❌️            | ⚠️          | ❌️          | N/A          |
| [npmjs](./docs/artifact-types/npmjs.md)                                   | ✅             | ⚠️          | ❌️          | N/A          |

_See the respective artifact type to learn about idempotency limitations ⚠️_

## Usage

All examples are structured by [artifact types](./docs/artifact-types/index.md) and [features](./README.md#features)

The example below shows how to publish binaries in S3:

```yaml
name: Release

on:
  push: # note that 'pull_request' and 'pull_request_target' are not supported
    branches:
      - main

jobs:
  Release:
    runs-on: ubuntu-latest
    environment: release # has secret GH_TOKEN - a PAT with permission to bypass branch protection rule
    permissions:
      contents: read     # to checkout code
      id-token: write    # to assume AWS role via OIDC
    steps:
      # (example) package AWS Lambda code as a zip archive in ./s3 directory
        
      - name: Release
        uses: agilecustoms/release@v1
        with:
          aws-account: ${{ vars.AWS_ACCOUNT_DIST }}
          aws-region: us-east-1
          aws-role: 'ci/publisher'
          aws-s3-bucket: 'mycompany-dist'
        env:
          GH_TOKEN: ${{ secrets.GH_TOKEN }}
```

Assume:
- you store artifacts in AWS account "Dist" and its number is stored in GH org variable `AWS_ACCOUNT_DIST`
- you have an S3 bucket `mycompany-dist` in `us-east-1` region
- there is a role `ci/publisher` with permissions to upload files in this S3 bucket and trust policy that allows to assume this role from GH action
- you have repo `mycompany/myapp`
- current release branch `main` has a protection rule so all changes must be done via PR
- you have a GH environment `release` associated with branch `main`
- There is a PAT (Personal Access Token) with permission to bypass the branch protection rule. This PAT is stored as environment secret `GH_TOKEN`
- the latest tag is `v1.2.3`

Scenario:
- a developer made a feature branch and a commit with message `feat: new-feature`
(alternatively use input [version-bump](./docs/features/version-generation.md#version-bump) for default minor/patch bump)
- the developer created and merged a PR which triggered a `Release` workflow
- build steps (omitted) produced a directory `./s3` with files (like a zip archive for AWS Lambda)

The action will:
- generate a new version `v1.3.0` (minor bump based on commit message prefix `feat:`)
- upload files from `./s3` directory to S3 bucket `mycompany-dist` at path `/myapp/v1.3.0/`
- update `CHANGELOG.md` with release notes
- push tags `v1.3.0`, `v1.3`, `v1` and `latest` to the remote repository
- create a GH Release tied to tag `v1.3.0`

## Inputs

_There are no required inputs. The action only controls that the combination of inputs is valid_

| Name                        | Default           | Description                                                                                                                                                                                                                                            |
|-----------------------------|-------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| aws-account                 |                   | AWS account to publish artifacts to. Not needed if there are no artifacts, just a git tag                                                                                                                                                              |
| aws-codeartifact-domain     |                   | AWS CodeArtifact domain name, e.g., `mycompany`                                                                                                                                                                                                        |
| aws-codeartifact-repository | (see description) | AWS CodeArtifact repository name, e.g., `maven`. If `aws-codeartifact-maven` is true, then default to `maven`                                                                                                                                          |
| aws-codeartifact-maven      |                   | If true, then publish maven artifacts to AWS CodeArtifact                                                                                                                                                                                              |
| aws-ecr                     |                   | If true, then push docker image to AWS ECR, [example](./docs/artifact-types/aws-ecr.md)                                                                                                                                                                |
| aws-region                  |                   | AWS region                                                                                                                                                                                                                                             |
| aws-role                    |                   | AWS IAM role to assume to publish, e.g., `ci/publisher`                                                                                                                                                                                                |
| aws-s3-bucket               |                   | AWS S3 bucket to upload artifacts to                                                                                                                                                                                                                   |
| aws-s3-dir                  |                   | Allows you to specify AWS S3 bucket directory to upload artifacts to. By default, just place in `bucket/{repo-name}/{version}/*`                                                                                                                       |
| changelog-file              | CHANGELOG.md      | Changelog file path. Pass an empty string to disable changelog generation                                                                                                                                                                              |
| changelog-title             | # Changelog       | Title of the changelog file (first line of the file)                                                                                                                                                                                                   |
| dev-branch-prefix           | feature/          | Allows you to enforce branch prefix for dev-releases; this helps to write auto-disposal rules. Empty string disables enforcement                                                                                                                       |
| dev-release                 | false             | Allows you to create a temporary named release, mainly for dev testing. Implementation is different for all supported artifact types                                                                                                                   |
| floating-tags               | true              | When next version to be released is `1.2.4`, then also release `1.2`, `1` and `latest`. Not desired for public terraform modules                                                                                                                       |
| npm-extra-deps              |                   | Additional npm dependencies needed to use non-default commit analyzer preset, e.g., `conventional-changelog-conventionalcommits@9.1.0`. Use white space or new line to specify multiple deps (extremely rare)                                          |
| npm-visibility              | public            | Used together with env variable `NPM_TOKEN` to publish npm package. Specifies package visibility: public or private (not tested yet). [Example](./docs/artifact-types/npmjs.md)                                                                        |
| node-version                | 22                | Node.js version to publish npm packages. Default is 22 because it is the highest pre-cached in Ubuntu 24 (latest at time of writing)                                                                                                                   |
| java-version                | 21                | Java version to use with input `aws-codeartifact-maven`. [Example](./docs/artifact-types/aws-codeartifact-maven.md)                                                                                                                                    |
| pre-publish-script          |                   | Custom sh script that allows you to update version in arbitrary file(s), not only files governed by build tool (pom.xml, package.json, etc.). In this script you can use variable `$version`. See example in [npmjs](./docs/artifact-types/npmjs.md)   |
| release-branches            | (see description) | Semantic-release [branches](https://semantic-release.gitbook.io/semantic-release/usage/configuration#branches), mainly used to support [maintenance releases](./docs/features/maintenance-release.md) and [prereleases](./docs/features/prerelease.md) |
| release-channel             |                   | Repeat `.releaserc.json` `channel` behavior when `version` is set explicitly. See [floating-tags](./docs/features/floating-tags.md) for details                                                                                                        |
| release-gh                  | true              | If true, then create a GitHub release                                                                                                                                                                                                                  |
| release-plugins             | (see description) | Semantic-release "plugins" configuration, see [details](./docs/configuration.md)                                                                                                                                                                       |
| summary                     | (see description) | Text to print in step summary. Can use `${version}` placeholder. Default is `### Released ${version}`. Set to an empty string to omit summary generation                                                                                               |
| tag-format                  | v${version}       | Default tag format is `v1.0.0` _(default is in code level, not input value)_. Use `${version}` to remove `v` prefix                                                                                                                                    |
| version                     |                   | [Explicit version](./docs/features/version-generation.md#explicit-version) to use instead of auto-generation                                                                                                                                           |
| version-bump                |                   | Allows you to [bump a version](./docs/features/version-generation.md#version-bump) without semantic commits                                                                                                                                            |

## Outputs

| Name              | Description                                                  |
|-------------------|--------------------------------------------------------------|
| version           | Version that was generated (or provided via `version` input) |

## Environment variables

| Name      | Description                                                                                                                                       |
|-----------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| GH_TOKEN  | Takes GH PAT with permission to bypass the branch and tags protection rules. See details in [Authorization and Security](./docs/authorization.md) |
| NPM_TOKEN | If specified, publish npm package in npmjs repo. See [details](./docs/artifact-types/npmjs.md)                                                    |

## Misc

- [More about this project](./docs/about.md): history, motivation
- [Troubleshooting](./docs/troubleshooting.md)
- [Contribution guideline](./docs/contribution.md)
- [Feature test coverage](./docs/test-coverage.md)

## License

This project is released under the [MIT License](./LICENSE)

## Acknowledgements

- https://github.com/semantic-release/semantic-release — NPM library to generate the next version and release notes. Used as essential part of `agilecustoms/release` action
- https://github.com/cycjimmy/semantic-release-action — GH action wrapper for `semantic-release` library. Used as a reference on how to write my own GH action-adapter for semantic-release
- https://github.com/anothrNick/github-tag-action — easy and powerful GH action to generate the next version and push it as a tag. Used it for almost 2 years until switched to semantic-release
