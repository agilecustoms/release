# Testing

This is an internal document describing feature/test coverage

## Versioning features

| feature                                                         | tested in             | last tested | notes |
|-----------------------------------------------------------------|-----------------------|-------------|-------|
| `changelog-file`: (none)                                        | gha-release           | 4.0.0       |       |
| conventional commits defaults                                   | gha-healthcheck       | 4.0.0       |       |
| custom summary w/ ${version}                                    | env-cleanup           | 1.0.0       |       |
| `dev-release` true                                              | tt-web                | 1.0.0       |       |
| explicit version w/ release-channel                             | env-cleanup           | 1.0.0       |       |
| `floating-tags` false                                           | terraform-github-repo | 2.0.0       |       |
| maintenance release                                             | java-parent           | 3.0.0       |       |
| `pre-publish-script`                                            | envctl                | 4.0.0       |       |
| prerelease w/ custom suffix and channel                         | release               | 1.0.0       |       |
| prerelease w/ `version-bump: default-patch` and `channel: beta` | db-evolution-runner   | 1.0.0       |       |
| `release-gh` false                                              | gha-release           | 4.0.0       |       |
| `tag-format`                                                    | gha-healthcheck       | 4.0.0       |       |
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
| node version                                     | tt-auth             | 4.0.0       |                                                                       |
| npm public                                       | envctl              | 3.1.0       |                                                                       |
| python poetry version update                     | env-api             | 4.0.0       |                                                                       |

## Security

| feature         | tested in   | last tested | notes                                                                |
|-----------------|-------------|-------------|----------------------------------------------------------------------|
| release w/o PAT | gha-release | 1.0.0       | just `permissions: contents: write` (no CHANGELOG.md, no GH release) |
