# Dev release

Besides normal releases, prereleases and maintenance releases, this action supports a special type of release called **dev-release**.
It sounds similar to prerelease, so let's clarify the difference:

**prerelease** is an industry standard, though some tools use different terms
like "prerelease" (GitHub), distribution tags (npm), suffix "-SNAPSHOT" (maven), suffixes "-beta", "rc" (Gradle, NuGet, PyPI, pip).
Idea: release a version widely available for testing and potential to become a next major release

**dev-release** is a way to overcome the inability to spin up the entire env locally.
It allows to temporarily release a version (= branch name), so that now you can deploy it in sandbox or dev environment for testing or POC.

The table below shows a comparison of different release types:

| Name                        | normal release and maintenance release | prerelease                            | dev-release           |
|-----------------------------|----------------------------------------|---------------------------------------|-----------------------|
| intention                   | use in production                      | beta testing                          | dev testing           |
| best use for                | software packages and deployable apps  | software packages and deployable apps | deployable apps       |
| adoption                    | widely                                 | widely                                | popular in enterprise |
| version generation          | "semantic commits" or "version-bump"   | "semantic commits" or "version bump"  | version = branch name |
| auto deletion               | ❌️                                     | ❌️                                    | ✅                     |
| number of developers        | many                                   | many                                  | typically one         |
| release notes and changelog | ✅                                      | ✅                                     | ❌️                    |
| floating tags               | major, minor, latest                   | alpha/beta/rc                         | ❌️                    |


Dev release allows publishing artifacts temporarily for testing purposes:
you push your changes to the feature branch, the branch name becomes this dev-release version:
- SemVer is _not_ generated
- no git tags created, files in branch addressable by branch name
- if branch name is `feature/login` then the version will be `feature-login`
- parameter `dev-branch-prefix` (default value is `feature/`) enforces branch naming for dev releases.
  This is needed for security and automatic resource disposal. Set to empty string to disable such enforcement (not recommended).
- for each [artifact type](./../artifact-types/index.md), dev-release might have different semantics, see `dev-release` section for each artifact type

Example of 'dev-release' usage with AWS S3:
```yaml
steps:
  - name: Release
    uses: agilecustoms/release@v1
    with:
      aws-account: ${{ vars.AWS_ACCOUNT_DIST }}
      aws-region: us-east-1
      aws-role: 'ci/publisher-dev' # see "Security" section below
      aws-s3-bucket: 'mycompany-dist'
      dev-release: true
      dev-release-prefix: 'feature/' # default
```

## Motivation

_How did we live w/o a dev-release before?
We do use microservices in our team, and we just have a CI/CD pipeline that can build a feature branch and deploy it to a dev server.
So we do not need dev-release, right?_

Build-and-deploy is kind of a "shortcut" and it may work in simple scenarios.
The reality is that a system is a _combination_ of multiple services and true deployment takes a combination of services!
Imagine a system that consists of two services A and B, and there is a repo C storing the current combination: `A@v1.0`, `B@v1.1`.
And only C has a "Deploy" button!
Now, you want to make a change in service A and test it, but since the only way to deploy a system is to deploy both services together,
you must create a temporary release of A. This is a dev-release!

## Configuration
 
`dev-release` mode takes precedence over normal release modes ("semantic commits", "version-bump" and "explicit version").
When `dev-release` is set to `true` it ignores most of the parameters that are used for normal releases.
These are only parameters respected by dev-release:
`aws-account`, `aws-ecr`, `aws-region`, `aws-role`, `aws-s3-bucket`, `aws-s3-dir`, `dev-branch-prefix`

There is no error if `dev-release` used with incompatible parameter (like `tag-format` or `floating-tags`).
General principle: ignore unused parameters, so that you can have one corporate gha wrapper for `agilecustoms/release`.

Only parameter that conflicts with `dev-release` is `version` as it looks like a complete mistake

## Security

1. Override existing artifact
2. Create unverified artifact that looks like normal

npm and python Poetry only support SemVer versions so no dev-release.
Maven on the other hand, allows arbitrary version format.
Originally up to beta-22 it was possible to dev-release maven package in CodeArtifact.
Problem is that there is no way to distinguish normal release from dev-release.
I (author) decided to not allow dev-release for CodeArtifact entirely

| Name         | non SemVer | overwrite | unreviewed next | auto cleanup |
|--------------|------------|-----------|-----------------|--------------|
| npmjs        | ❌️         | ✅ safe    | ❌️ unsafe       | ❌️           |
| CodeArtifact | ✅          | ✅ safe    | ❌️ unsafe       | ❌️           |
| S3           | ✅          | ✅ safe    | ✅ safe          | ✅            |
| ECR          | ✅          | ✅ safe    | ❌️ unsafe       | ✅            |

