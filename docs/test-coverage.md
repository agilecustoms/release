# Testing

This is an internal document describing feature/test coverage

Features covered by tests in [build.yml](../.github/workflows/build.yml) (jobs `Input-Validation` and `E2E-*`) are not listed here.
Version generation (conventional commits, floating tags, explicit version etc.) is also covered by [release-gen](https://github.com/agilecustoms/release-gen) integration tests.
This document only lists features that are tested by real releases in other repos

## Versioning features

| feature                                                         | tested in             | last tested | notes |
|-----------------------------------------------------------------|-----------------------|-------------|-------|
| custom summary w/ ${version}                                    | env-cleanup           | 1.0.0       |       |
| `dev-release` true                                              | tt-web                | 1.0.0       |       |
| `release-channel` w/ explicit version                           | env-cleanup           | 1.0.0       |       |
| maintenance release                                             | java-parent           | 3.0.0       |       |
| prerelease w/ custom suffix and channel                         | release               | 1.0.0       |       |
| prerelease w/ `version-bump: default-patch` and `channel: beta` | db-evolution-runner   | 1.0.0       |       |
| version-bump: `default-minor` + release-channel                 | gha-release           | 4.0.0       |       |
| version-bump: `default-patch`                                   | db-evolution-runner   | 4.0.0       |       |

## Artifact types

| feature                                          | tested in           | last tested | notes                                                                 |
|--------------------------------------------------|---------------------|-------------|-----------------------------------------------------------------------|
| aws codeartifact maven `publish`                 | java-parent         | 4.0.0       |                                                                       |
| aws codeartifact maven `build`                   | db-evolution-runner | 4.0.0       |                                                                       |
| dev-release "skip" npm publish                   | envctl              | 1.0.0       |                                                                       |
| dev-release in ECR                               | envctl              | 1.0.0       | attempt to overwrite existing image, attempt to delete existing image |
| dev-release of S3 w/ disabled suffix enforcement | tt-web              | 1.0.0       |                                                                       |
| npm public                                       | envctl              | 3.1.0       |                                                                       |
| python uv.lock update                            | env-api             | 5.3.0       |                                                                       |

## Security

| feature         | tested in   | last tested | notes                                                                |
|-----------------|-------------|-------------|----------------------------------------------------------------------|
| release w/o PAT | gha-release | 1.0.0       | just `permissions: contents: write` (no CHANGELOG.md, no GH release) |
