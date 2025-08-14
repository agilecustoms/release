# Testing

This is an internal document describing feature/test coverage

**release**
- prerelease w/ custom suffix and channel - 1.0.0-beta4

**gha-release**
- release w/o PAT, just `permissions: contents: write` (no CHANGELOG.md, no GH release) - 1.0.0-beta11
- version-bump: default-minor + `release-channel` - 1.0.0-beta4

**envctl**
- npm public - 1.0.0-beta2
- npm private - not tested

**java-parent**
- dev-release aws-codeartifact-maven - not tested
- prerelease aws-codeartifact-maven - not tested

**db-evolution-runner**
- prerelease w/ `version-bump: default-patch` and `channel: beta` - 1.0.0-beta6

**env-cleanup**
- explicit version
- custom summary with ${version} - 1.0.0-beta2
