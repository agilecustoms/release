# About the project

## History

In 2023, I (Alexey Chekulaev) started to work on a project that consists of multiple microservices hosting in AWS.
First, I did not find a good GH action to upload files in S3, so I did one myself.
Then I felt a lack of GH action to publish Maven packages in AWS CodeArtifact, so I had to develop two more actions:
one to publish and one to resolve existing packages.
In spring 2025 I started my second project, the number of services grew and so grew a volume of similar code in release pipelines.
Then I combined all of them into a single action `agilecustoms/gha-release`.
But then (summer 2025) I decided to make it public and extracted stuff not specific to AgileCustoms into a separate action `agilecustoms/release`.
Fall 2025 first version of `agilecustoms/release-gen` was released

## Current state

Currently (July 2025) this action is being used in two private AgileCustoms projects with over 20+ repositories,
which allows me as the author to have good coverage of different release scenarios

Did I think about a plugin system? Yes, I did. Having every type of artifact as a plugin would be great.
The problem is that right now this GH action is a combination of other GH actions, my custom GH actions (composite and Node.js ones) and some shell scripts.
Ideally (maybe in the future) rewrite the whole thing in TypeScript or Go and then allow plugins with clear programmatic API

So far the idea is to add new types of artifacts as new steps in `action.yml` file, even though it is a "monolithic" approach

## Philosophy

1. Everything works out of the box, minimal setup is needed; inputs have meaningful defaults
2. Implement features only when they are needed and thus can be tested!
3. Very thoughtful and detailed documentation, including examples for each use case

## Why not just use [semantic-release](https://github.com/semantic-release/semantic-release)?

1. I found it somewhat hard to learn and configure: it is like a Lego set, not all plugins have good quality and documentation.
I wanted to have a GH action that works fine by default and clear usecase-based documentation
with examples of how to configure the action per specific use case
2. Semantic-release as of June 2025 has no plugins to 1) upload files in S3, 2) publish Docker images to ECR, 3) publish maven in CodeArtifact
3. Semantic-release is good for open source projects where people diligently follow commit message conventions.
Enterprise projects tend to use a simplified approach: no release notes, no changelog, just bump a minor version and publish

Internally `semantic-release` uses `conventional-changelog`. At some point I thought about using `conventional-changelog` directly,
but then I realized that `conventional-changlog` itself is a "Lego" - you need at least next 4 libraries:
conventional-changelog-conventionalcommits, conventional-commits-parser, conventional-changelog-filter, conventional-changelog-writer.
So `semantic-release` does some heavy lifting to put them together
