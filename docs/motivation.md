# Motivation

## why not `semantic-release`?
1. `semantic-release` in its core part has focus on release of npm packages, see `release_channel` which is npm specific
2. `semantic-release` as of June 2025 has no plugins to 1) upload files in S3, 2) publish Docker images to ECR, 3) publish maven in CodeArtifact
3. `semantic-release` is a library. To use it as GH action, you need a wrapper, like [semantic-release-action](https://github.com/cycjimmy/semantic-release-action)
4. conceptually I found `semantic-release` somewhat hard to learn and configure,
I wanted to have a GH action that works fine by default and clear usecase-based documentation with examples
how to configure the action per specific use case

Internally `semantic-release` uses `conventional-changelog`. At some point I thought about using `conventional-changelog` directly,
but then I realized that `conventional-changlog` itself is a "Lego" - you need at least next 4 libraries:
conventional-changelog-angular, conventional-commits-parser, conventional-changelog-filter, conventional-changelog-writer.
So `semantic-release` does some heavy lifting to put them together.
