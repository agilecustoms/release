# About

Your Swiss Army knife to publish/release software in AWS (and more) with GitHub action.
This action:
1) publish software artifacts in AWS S3, ECR, CodeArtifact; also in npmjs and [more](./docs/use-cases.md)
2) git commit and push tags
3) generate GH release

_Called it 'publish' bcz it takes most effort, whereas GitHub 'release' is optional and relatively simple.
Terms 'publish' and 'release' are used interchangeably_

![Cover](docs/images/cover.png)

Main use case — microservices that hold application code and infrastructure code (like Terraform). Not designed/tested for monorepos.
The action generates a new version based on latest [SemVer](https://semver.org) tag and [semantic commits](./docs/semantic-release.md) `fix:`, `feat:` and `BREAKING CHANGE:`.
Then publish artifacts and push git tags, so your artifacts and git tags are in sync!

## --> [🔗 All use cases](./docs/use-cases.md)

Example of publish in S3:
```yaml
steps:
  # (example) package AWS Lambda code in a .zip archive in ./s3 directory
  
  - name: Release
    uses: agilecustoms/publish@v1
    with:
      aws-account: ${{ vars.AWS_ACCOUNT_DIST }}
      aws-region: us-east-1
      aws-role: 'ci/publisher' # default
      aws-s3-bucket: 'mycompany-dist'
```
Assume:
- repo name is `mycompany/myapp`
- workflow is run on PR merge in branch 'main' which has latest SemVer tag `v1.2.3`
- merged branch has commit `feat: new-feature`
- you have an S3 bucket `mycompany-dist` in `us-east-1` region
- there is a role `ci/publisher` in AWS account `AWS_ACCOUNT_DIST` with permissions to upload files in this S3 bucket

The action will:
- generate a new version `v1.3.0`
- upload files from `./s3` directory to S3 bucket `mycompany-dist` at path `mycompany-dist/myapp/v1.3.0/`
- push tag `v1.3.0` to the remote repository
- create GH Release and update CHANGELOG.md

## Artifact types and features:

| Name                   | floating tags<br>release, prerelease | idempotency | prerelease | dev-release,<br>auto cleanup |
|------------------------|--------------------------------------|-------------|------------|------------------------------|
| git                    | ✅ ?                                  | ✅           |            | ✅ N/A                        |
| AWS S3                 | ✅ ?                                  | ✅           |            | ✅ ✅                          |
| AWS ECR                | ✅ ?                                  | ✅           |            | ✅ ✅                          |
| AWS CodeArtifact maven | N/A N/A                              | ⚠️          |            | ✅ ❌️                         |
| GitHub releases        | ? ?                                  | ?           | planned    | ?                            |
| npmjs public repo      | planned ?                            | ⚠️          |            | ❌️ N/A                       |

Features:
- **floating tags** — given current version is `1.2.3` and you release `1.2.4` then also create `1`, `1.2` and `latest` tags
- **idempotency** — ability to re-run the action w/o side effects, see below for more details
- **prerelease** — version of software that is made available before the official, stable release
- **dev-release** — ability to publish artifacts for dev testing when testing on local machine impossible/complicated

More details about [release types](./docs/release-types.md)

## Action steps

1. Validate
2. Release generation
   1. generate a new version based on the latest SemVer tag + git commit messages
   2. generate release notes (write in /tmp file)
   3. update CHANGELOG.md
3. Login in AWS
4. Prepare: mainly bump versions in language-specific files
   1. update version in `pom.xml` (for maven)
   2. update version in `package.json` (for npm)
   3. run a custom script to update arbitrary files
5. Publish artifacts
   1. AWS S3 - upload files in S3 bucket, files need to be in `./s3` directory
   2. AWS ECR - publish Docker image in ECR repository
   3. AWS CodeArtifact maven - publish maven package in CodeArtifact repository
   4. npmjs - publish npm package in public npmjs.com repository
6. Git push
   1. commit changes from step 4
   2. besides SemVer 'major.minor.patch', also add floating tags 'major', 'major.minor' and 'latest'
   3. atomically push commit and tags to the remote repository
7. GitHub release
   1. create a GitHub release tied to the most recent tag
8. Print summary

### Idempotency

This GH action does three modify operations: "Publish artifacts", "Git push" and "GitHub release".
Order is important to recover from failures:

- **Publish artifacts** goes first as it is most complex (highest chances to fail).
It is idempotent, so if a later step fails, it is safe to re-run "Publish artifacts".<br>
_Note: some publish commands are not idempotent (like npm publish), so as workaround just swallow 'same version already exists' type of errors
if it is already not first workflow run (use `${{ github.run_attempt }}`)_

- **Git push** goes next as it is much simpler and less likely to fail. And it is _not_ idempotent, given "Git push" succeed,
an attempt to run it again will cause new tags creation!

- **GitHub release** goes last, as it is optional. It is also very simple — just one command
(provided all release notes/files are generated on previous steps).
If it fails, you can create release manually through GitHub UI

## semantic-release usage

NPM library [semantic-release](https://github.com/semantic-release) is used to generate the next version and release notes.
It takes latest SemVer tag and analyzes commit messages to determine the next version:
commits with `fix:` prefix will increment a patch version, commits with `feat:` prefix will increment a minor version,
and commits with `BREAKING CHANGE:` will increment a major version.
For more details see [semantic-release usage](./docs/semantic-release.md).

## GitHub authorization

Most of the time GitHub repos have protected branch such as `main` which requires to be made only via PRs.
At the same time, release workflow often assumes some automated changes, such as bump versions `package.json` or update `CHANGELOG.md`.
In this setup you need to **bypass** branch protection rule to make direct commit and push.
This requires a PAT ([Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)) issued by a person who has permission to bypass these branch protection rules.
So this is the main use case for `agilecustoms/publish` action. For more details see [GitHub authorization](./docs/gh-authorization.md) 

```yaml
jobs:
   Release:
      runs-on: ubuntu-latest
      permissions:
         id-token: write # need for AWS login (via GitHub OIDC provider)
         contents: read # since `id-token` is specified, now need to explicitly set `contents` permission, otherwise can't even checkout
      steps:
         - name: Checkout
           uses: actions/checkout@v4

         # ...

         - name: Release
           uses: agilecustoms/publish@v1
           env:
              GH_TOKEN: ${{ secrets.GH_TOKEN }} # PAT to bypass branch protection. Create PAT and put it in repo/org secrets
```

## Inputs

| Name                        | Default           | Description                                                                                                                                                                                                                  |
|-----------------------------|-------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| aws-account                 |                   | AWS account to publish artifacts to. Not needed if there are no artifacts, just git tag                                                                                                                                      |
| aws-region                  |                   | AWS region                                                                                                                                                                                                                   |
| aws-role                    |                   | IAM role to assume to publish, ex. `/ci/publisher`                                                                                                                                                                           |
| aws-codeartifact-domain     |                   | CodeArtifact domain name, ex. `mycompany`                                                                                                                                                                                    |
| aws-codeartifact-repository |                   | CodeArtifact repository name, ex. `maven`                                                                                                                                                                                    |
| aws-codeartifact-maven      |                   | If true, then publish maven artifacts to AWS CodeArtifact                                                                                                                                                                    |
| aws-ecr                     |                   | If true, then push docker image to ECR                                                                                                                                                                                       |
| aws-s3-bucket               |                   | S3 bucket to upload artifacts to                                                                                                                                                                                             |
| aws-s3-dir                  |                   | Allows to specify S3 bucket directory to upload artifacts to. By default just place in `bucket/{repo-name}/{version}/*`                                                                                                      |
| changelog-file              | CHANGELOG.md      | CHANGELOG.md file path. Pass empty string to disable changelog generation                                                                                                                                                    |
| changelog-title             | # Changelog       | Title of the changelog file (first line of the file)                                                                                                                                                                         |
| dev-release                 | false             | Allows to create temporary named release, mainly for dev testing. Implementation is different for all supported artifact types                                                                                               |
| dev-branch-prefix           | dev/              | Allows to enforce branch prefix for dev-releases, this help to write auto-disposal rules. Empty string disables enforcement                                                                                                  |
| floating-tags               | true              | When next version to be released is 1.2.4, then also release 1, 1.2 and latest. Not desired for public terraform modules                                                                                                     |
| npm-extra-deps              |                   | Additional semantic-release npm dependencies, needed to use non-default commit analyzer preset, ex. `conventional-changelog-conventionalcommits@9.1.0` use white space or new line to specify multiple deps (extremely rare) |
| node-version                | 22                | Node.js version to publish npm packages, default is 22 (pre-cached in Ubuntu 24)                                                                                                                                             |
| pre-publish-script          |                   | custom sh script that allows to update version in arbitrary file(s), not only files governed by build tool (pom.xml, package.json, etc). In this script you can use variable `$version`                                      |
| release-branches            | (see description) | semantic-release "branches" configuration, see default at [gitbook](https://semantic-release.gitbook.io/semantic-release/usage/configuration?utm_source=chatgpt.com#branches)                                                |
| release-gh                  | true              | If true, then create a GitHub release                                                                                                                                                                                        |
| release-plugins             | (see description) | semantic-release "plugins" configuration, see [details](./docs/semantic-release.md#Configuration)                                                                                                                            |
| summary                     | (see description) | Text to print in workflow 'Release summary'. Default is `### Released ${version}`. Set empty string to omit summary generation                                                                                               |
| tag-format                  | v${version}       | Default tag format is `v1.0.0` _(default is in code level, not input value)_. Use `${version}` to remove `v` prefix                                                                                                          |
| version                     |                   | Explicit version to use instead of auto-generating. When provided, only this single version/tag will be created (no `latest`, `major`, `minor` tags)                                                                         |

## Environment variables

| Name             | Description                                                                                                                                                          |
|------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| GH_TOKEN         | 95% you pass GH PAT with protected branch bypass permission. Required if `release-gh: true` (default). See details in [gh-authorization](./docs/gh-authorization.md) |
| NPM_PUBLIC_TOKEN | If specified - will publish an npm package in public npmjs repo                                                                                                      |

## Outputs

| Name              | Description                                                  |
|-------------------|--------------------------------------------------------------|
| version           | Version that was generated (or provided via `version` input) |

## Misc

- [More about this project](./docs/history.md): history, motivation, why not just use "semantic-release"
- [Contribution guideline](./docs/contribution.md)

**Credits:**
- https://github.com/semantic-release/semantic-release — NPM library to generate the next version and release notes. Used as essential part of `agilecustoms/publish` action
- https://github.com/cycjimmy/semantic-release-action — GH action wrapper for `semantic-release` library. Used as reference on how to write my own GH action-adapter for semantic-release
- https://github.com/anothrNick/github-tag-action — easy and powerful GH action to generate the next version and push it as tag. Used it for almost 2 years until switched to semantic-release
