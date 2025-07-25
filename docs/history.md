# History

In 2023, I (Alexey Chekulaev) started to work on a project that consists of multiple microservices hosting in AWS.
First, I did not find a good GH action to upload files in S3, so I did one myself.
Then I felt a lack of GH action to publish Maven packages in AWS CodeArtifact, so I had to develop two more actions:
one to publish and one to resolve existing packages.
In spring 2025 I started my second project, and the number of services grew as a volume of similar code in release pipelines.
Then I combined all of them into a single action `agilecustoms/gha-release`.
But then (summer 2025) I decided to make it public and extracted stuff not specific to AgileCustoms into a separate action `agilecustoms/release`

## why not just use `semantic-release`?

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
