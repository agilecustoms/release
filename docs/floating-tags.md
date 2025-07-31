# Floating tags and release channel

**Floating tags** are tags that move! When you release `1.2.4` then tags `1` and `1.2` move to point to `1.2.4`.
This feature primarily supported by Git. Docker images also use tags.
AWS S3 mimics file system structure so given objects (files) in a path (dir) `1.2` - you can remove and override them.
So S3 also supports floating tags.

**Release channel** is a term specific to NPM, where you can publish a package to a specific channel, like `latest`, `beta`, or `next`.
For git, Docker and S3 the release channel is a tag!

Basic use case is when you want to add a tag `latest` to the latest release from the `main` branch.

Consider 4 branches:
- `1.1.x` - maintenance branch for the old version, only patches are applied, currently at v _1.1.10_
- `1.x.x` - maintenance branch for the previous version, currently at v _1.5.5_
- `main` - main release branch, currently at v _2.2.2_
- `beta` - prerelease branch for next version, currently at v _3.0.0-beta.3_

Given input `floating-tags` is `true` (default):

| branch -> new version     | input channel | result channel |  git tags                       | Docker tags and S3 dirs      |
|---------------------------|---------------|----------------|---------------------------------|------------------------------|
| `1.1.x` -> _1.1.11_       |               |                |  `1.1.11`, `1.1`                | _same_                       |
| `1.1.x` -> _1.1.11_       | 1.1.x         | 1.1.x          |  `1.1.11`, `1.1`                | `1.1.11`, `1.1`, `1.1.x`     |
| `1.1.x` -> _1.1.11_       | legacy        | legacy         |  `1.1.11`, `1.1`, `legacy`      | _same_                       |
| `1.x.x` -> _1.6.0_        |               |                |  `1.6.0`, `1.6`, `1`            | _same_                       |
| `1.x.x` -> _1.6.0_        | 1.x.x         | 1.x.x          |  `1.6.0`, `1.6`, `1`            | `1.6.0`, `1.6`, `1`, `1.x.x` |
| `1.x.x` -> _1.6.0_        | support       | support        |  `1.6.0`, `1.6`, `1`, `support` | _same_                       |
| `main`  -> _2.3.0_        |               | latest         |  `2.3.0`, `2.3`, `2`, `latest`  | _same_                       |
| `main`  -> _2.3.0_        | ' '           |                |  `2.3.0`, `2.3`, `2`            | _same_                       |
| `main`  -> _2.3.0_        | main          | main           |  `2.3.0`, `2.3`, `2`            | `2.3.0`, `2.3`, `2`, `main`  |
| `main`  -> _2.3.0_        | release       | release        |  `2.3.0`, `2.3`, `2`, `release` | _same_                       |
| `beta`  -> _3.0.0-beta.4_ |               | beta           |  `3.0.0-beta.4`                 | `3.0.0-beta.4`, `beta`       |
| `beta`  -> _3.0.0-beta.4_ | ' '           | beta           |  `3.0.0-beta.4`                 | `3.0.0-beta.4`, `beta`       |
| `beta`  -> _3.0.0-beta.4_ | beta          | beta           |  `3.0.0-beta.4`                 | `3.0.0-beta.4`, `beta`       |
| `beta`  -> _3.0.0-beta.4_ | next          | next           |  `3.0.0-beta.4`, `next`         | _same_                       |

Rules:
- `dev-release` and explicit `version` never have floating tags
- if `floating-tags` is `false` then no floating tags (old ones do not move, new ones are not created)
- prerelease can only have a release channel tag (no numerical floating numbers)
- prerelease must have a release channel, you can't disable it by specifying empty `release-channel` input
- maintenance and prerelease by default do not have a release channel tag
- maintenance release from branch like `1.1.x` only gives floating tag of `1.1`, no `1`
- normal release by default has a release channel tag `latest`, you can explicitly set input `release-channel` to disable it
- if a release channel equals to branch name, then the corresponding git tag is not created, but docker tag and S3 dir are created
- `release-channel` input has precidence over `channel` property in `branches` configuration in `.releaserc.json`
