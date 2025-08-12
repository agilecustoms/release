# About

**This GH action is beta-testing now, planned to be released late Aug 2025**

Release software artifacts in AWS (S3, ECR, CodeArtifact) and NPM with consistent versioning!

![Cover](docs/images/cover.png)

You can release **any combination** of software packages, binary files, docker images and raw repo files

This is especially useful in microservices where the release is a _binary_ + _IaC_ versioned via git tag

The action comes with an **ecosystem**:
- Terraform modules to provide AWS roles and policies to [read](https://registry.terraform.io/modules/agilecustoms/ci-builder/aws/latest) and [publish](https://registry.terraform.io/modules/agilecustoms/ci-publisher/aws/latest) artifacts
- complimentary GitHub actions to use in build workflows ex. [setup-maven-codeartifact](https://github.com/agilecustoms/setup-maven-codeartifact)
- documentation / examples for all supported [artifact types](./docs/artifact-types/index.md)

## Features:

- automatic and manual [version generation](./docs/features/version-generation.md)
- release notes generation and changelog update
- [floating tags](./docs/features/floating-tags.md) — given current version is `1.2.3` and you release `1.2.4` then also create/move tags `1.2`, `1` and `latest`
- [maintenance releases](./docs/features/maintenance-release.md) — made from branch like `1.x.x` (given `2.x.x` development is in `main`)
- [prereleases](./docs/features/prerelease.md) — develop a next (often major, sometimes minor) version, typically made from a branch `next`
- [dev-release](./docs/features/dev-release.md) — ability to publish artifacts for dev testing when testing on a local machine is impossible/complicated
- [idempotency](./docs/features/idempotency.md) — ability to re-run the action w/o side effects
- GitHub release
- [GitHub authorization](./docs/features/gh-authorization.md)
- [AWS authorization](./docs/features/aws-authorization.md)

## Artifact types <-> features:

| Artifact type                                                             | floating tags | idempotency | dev-release — auto cleanup |
|---------------------------------------------------------------------------|---------------|-------------|----------------------------|
| [git](./docs/artifact-types/git.md)                                       | ✅             | ✅           | ✅ — ❌️                     |
| [AWS S3](./docs/artifact-types/aws-s3.md)                                 | ✅             | ✅           | ✅ — ✅                      |
| [AWS ECR](./docs/artifact-types/aws-ecr.md)                               | ✅             | ✅           | ✅ — ✅                      |
| [AWS CodeArtifact maven](./docs/artifact-types/aws-codeartifact-maven.md) | ❌️            | ⚠️          | ✅ — ❌️                     |
| [npmjs](./docs/artifact-types/npmjs.md)                                   | ✅             | ⚠️          | ❌️                         |

_See the respective artifact type to learn about idempotency limitations ⚠️_

## Usage

All examples are structured by [artifact types](./docs/artifact-types/index.md) and [features](./README.md#features)

The example below shows how to publish binaries in S3

```yaml
name: Release

on:
  push: # note that 'pull_request' and 'pull_request_target' are not supported
    branches:
      - main

jobs:
  Release:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write
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
- you store artifacts in AWS account "Dist" and its number stored in org variable `AWS_ACCOUNT_DIST`
- you have an S3 bucket `mycompany-dist` in `us-east-1` region
- there is a role `ci/publisher` with permissions to upload files in this S3 bucket
- you have repo `mycompany/myapp`
- current release branch `main` has protection rule so all changes must be done via PR.
And also there is a PAT (Personal Access Token) with permission to bypass branch protection rule stored in repo secret `GH_TOKEN`
- latest tag is `v1.2.3`

Scenario:
- developer made a feature branch and a commit with message `feat: new-feature`
(alternatively use input [version-bump](./docs/features/version-generation.md#version-bump) for default minor/patch bump)
- the developer created and merged a PR which triggered a `Release` workflow
- build steps (omitted) produced a directory `./s3` with files that need to be released to S3

The action will:
- generate a new version `v1.3.0`
- upload files from `./s3` directory to S3 bucket `mycompany-dist` at path `/myapp/v1.3.0/`
- update `CHANGELOG.md` with release notes
- push tags `v1.3.0`, `v1.3`, `v1` and `latest` to the remote repository
- create GH Release tied to tag `v1.3.0`

## Inputs

_There are no required inputs. The action only controls that combination of inputs is valid_

| Name                        | Default           | Description                                                                                                                                                                                                                                                                                 |
|-----------------------------|-------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| aws-account                 |                   | AWS account to publish artifacts to. Not needed if there are no artifacts, just git tag                                                                                                                                                                                                     |
| aws-region                  |                   | AWS region                                                                                                                                                                                                                                                                                  |
| aws-role                    |                   | IAM role to assume to publish, ex. `/ci/publisher`                                                                                                                                                                                                                                          |
| aws-codeartifact-domain     |                   | CodeArtifact domain name, ex. `mycompany`                                                                                                                                                                                                                                                   |
| aws-codeartifact-repository |                   | CodeArtifact repository name, ex. `maven`                                                                                                                                                                                                                                                   |
| aws-codeartifact-maven      |                   | If true, then publish maven artifacts to AWS CodeArtifact                                                                                                                                                                                                                                   |
| aws-ecr                     |                   | If true, then push docker image to ECR                                                                                                                                                                                                                                                      |
| aws-s3-bucket               |                   | S3 bucket to upload artifacts to                                                                                                                                                                                                                                                            |
| aws-s3-dir                  |                   | Allows to specify S3 bucket directory to upload artifacts to. By default just place in `bucket/{repo-name}/{version}/*`                                                                                                                                                                     |
| changelog-file              | CHANGELOG.md      | Changelog file path. Pass empty string to disable changelog generation                                                                                                                                                                                                                      |
| changelog-title             | # Changelog       | Title of the changelog file (first line of the file)                                                                                                                                                                                                                                        |
| dev-release                 | false             | Allows to create temporary named release, mainly for dev testing. Implementation is different for all supported artifact types                                                                                                                                                              |
| dev-branch-prefix           | feature/          | Allows to enforce branch prefix for dev-releases, this help to write auto-disposal rules. Empty string disables enforcement                                                                                                                                                                 |
| floating-tags               | true              | When next version to be released is `1.2.4`, then also release `1.2`, `1` and `latest`. Not desired for public terraform modules                                                                                                                                                            |
| npm-extra-deps              |                   | Additional npm dependencies, needed to use non-default commit analyzer preset, ex. `conventional-changelog-conventionalcommits@9.1.0` use white space or new line to specify multiple deps (extremely rare)                                                                                 |
| npm-visibility              | public            | Used together with env variable `NPM_TOKEN` to publish npm package. Specifies package visibility: public or private                                                                                                                                                                         |
| node-version                | 22                | Node.js version to publish npm packages, default is 22 because it is highest pre-cached in Ubuntu 24                                                                                                                                                                                        |
| pre-publish-script          |                   | Custom sh script that allows to update version in arbitrary file(s), not only files governed by build tool (pom.xml, package.json, etc). In this script you can use variable `$version`                                                                                                     |
| release-branches            | (see description) | Semantic-release [branches](https://semantic-release.gitbook.io/semantic-release/usage/configuration?utm_source=chatgpt.com#branches) (see default), mainly used to support [maintenance releases](./docs/features/maintenance-release.md) and [prereleases](./docs/features/prerelease.md) |
| release-gh                  | true              | If true, then create a GitHub release                                                                                                                                                                                                                                                       |
| release-plugins             | (see description) | Semantic-release "plugins" configuration, see [details](./docs/features/configuration.md)                                                                                                                                                                                                   |
| summary                     | (see description) | Text to print in workflow 'Release summary'. Default is `### Released ${version}`. Set empty string to omit summary generation                                                                                                                                                              |
| tag-format                  | v${version}       | Default tag format is `v1.0.0` _(default is in code level, not input value)_. Use `${version}` to remove `v` prefix                                                                                                                                                                         |
| version                     |                   | [Explicit version](./docs/features/version-generation.md#explicit-version) to use instead of auto-generation                                                                                                                                                                                |
| version-bump                |                   | Allows to [bump a version](./docs/features/version-generation.md#version-bump) w/o semantic commits                                                                                                                                                                                         |

## Outputs

| Name              | Description                                                  |
|-------------------|--------------------------------------------------------------|
| version           | Version that was generated (or provided via `version` input) |

## Environment variables

| Name      | Description                                                                                                                                                                   |
|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| GH_TOKEN  | Takes GH PAT with permission to bypass branch protection rule. Required if `release-gh: true` (default). See details in [gh-authorization](docs/features/gh-authorization.md) |
| NPM_TOKEN | If specified — publish npm package in npmjs repo. See [details](./docs/artifact-types/npmjs.md)                                                                               |

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
