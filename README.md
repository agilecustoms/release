# About
Reusable GitHub Action `gha-release` allows to release microservices that hold application code and infrastructure code (like Terraform).
Since Terraform is distributed as source code via git tags, the action uses git tags as source of truth for versioning.
It generates new version based on current git tags and commit tags `#patch`, `#minor`, `#major`, then synchronously pushes new git tag and publishes artifacts with same version

1. Generate new version based on the latest tag + git commit message: #major, #minor, #patch
2. Update version in code (`package.json`, `pom.xml`) and commit
   1. maven (java-parent)
   2. npm (envctl)
   3. custom (envctl to update cache key!)
3. Git push
   1. commit changes from step 2
   2. add tags 'major', 'major.minor', 'major.minor.patch' and 'latest'
   3. atomically push commit and tags to the remote repository
4. Publish artifacts
   1. AWS S3 - upload files in S3 bucket, files need to be in `./s3` directory. Supports dev-release
   2. AWS ECR - publish Docker image in ECR repository
   3. AWS CodeArtifact maven - publish maven package in CodeArtifact repository
   4. npmjs - publish npm package in npmjs.com repository

Limitations:
- only `on: push` event is supported - covers both direct push and PR merge. `on: pull_request` is not supported
- when use `on: push` then semver tag `#patch`, `#minor`, `#major` is taken only from last commit message, keep it in mind when merging PRs
- only `main` branch is supported for now
These limitations should be gone in future, see roadmap

Note: first I do git "Git push" and then "Publish artifacts", so that if publish fails, I can re-run release workflow.
Of course, the price is dangling git tag. If publish fails painfully, we can easily roll back git tag!

Note for contributors: if you want to add support say for Google Cloud Docker Repository:
- add parameters with prefix 'gc-'
- if artifact is tag based, make sure you publish several tags: 'latest', 'major', 'major.minor', 'major.minor.patch'

## Inputs
- `tag-context` - Context for tag generation: 'repo' (default) or 'branch'.
  Use 'branch' to release from non-main long-living branches such as v1-support (given v2 is in main).
  Also use 'actions/checkout' with 'fetch-depth: 0'
- `version` - version to use, if not provided, will be generated based on latest tag and commit message

## Outputs
- `version` - version that was used/generated

## Setup
1. Pick AWS account for publishing artifacts, place it in `vars.AWS_ACCOUNT_DIST`
2. Create S3 bucket to publish raw artifacts, ECR repository for Docker images, CodeArtifact for software packages
3. Create IAM role `ci/publisher` with respective permissions: `s3:PutObject`, `ecr:PutImage`, `codeartifact:PublishPackageVersion` etc.<br>
   Reference role can be found in `iam.tf` file in this repo
4. (Important!) we're not going to use `aws-access-key-id` and `aws-secret-access-key` in the action, even through variables, this is not secure
   Instead we'll use OpenID provider, see example in `iam.tf` file in this repo

## Main use cases

### git tag only
For example, for repository with terraform code only - no binaries, just add git tag<br>
Version will be automatically generated based on current tags + consider commit message tag `#major`, `#minor`, `#patch`<br>
Ex: if current tag is `1.2.3` and commit has #patch, then the new tag will be `1.2.4`.
Also tags `1`, `1.2` and `latest` will be overwritten to point to the same commit as `1.2.4`
```yaml
jobs:
   Release:
      runs-on: ubuntu-latest
      permissions:
         contents: write
      steps:
         - name: Checkout
           uses: actions/checkout@v4

         - name: Release
           uses: agilecustoms/release@main
```
Note: adding/overwriting tags requires GH job permissions `content: write`

### publish in AWS S3
Convention: there should be `s3` directory in cwd. All content of this directory will be uploaded in S3 bucket<br>
Ex: if current tag is '1.2.3' and commit has #patch, then files will be uploaded to `s3-bucket/s3-bucket-dir/1.2.4`
Also files will be uploaded in dirs `/1`, `/1.2` and `/latest` - previous content of these dirs will be cleaned up
```yaml
steps:
  - name: Release
    uses: agilecustoms/release@main
    with:
      aws-account: ${{ vars.AWS_ACCOUNT_DIST }} # required, no default
      aws-region: us-east-1 # required, no default
      aws-role: 'ci/builder' # no default
      aws-s3-bucket: '{company-name}-dist' # no default
      aws-s3-bucket-dir: '{current-repo-name}' # default
```
`s3-bucket-dir` is empty by default, so files will be uploaded to `s3-bucket/{current-repo-name}/{version}/{files from ./s3 directory}`<br>
Convention: publishing of all AWS types of artifacts require `aws-account`, `aws-region` and `aws-role` parameters

### publish in AWS ECR
First you build docker image, and then you release it with this action.
Same as git tags, when you release version `1.2.3` with commit message `#patch`,
new docker image will be tagged as `1.2.4`, and tags `1`, `1.2` and `latest` will be overwritten to point to the same image as `1.2.4`
```yaml
steps:
  - name: Docker build
    run: docker build

  - name: Release
    uses: agilecustoms/release@main
    with:
      aws-account: ${{ vars.AWS_ACCOUNT_DIST }} # required, no default
      aws-region: us-east-1 # required, no default
      aws-role: 'ci/builder' # no default
      aws-ecr: true # default '' (effectively false)
```

### publish in AWS CodeArtifact
TBD

### publish in npmjs
TBD



## Additional use cases

### release from non-main branch
Assume main development (v2.x) is conducted in `main` branch, while version 1.x is maintained in `v1-support` branch.
If you want to make release in support branch, you need
1. run actions/checkout with with `fetch-depth: 0`
2. pass parameter `tag-context: branch`
```yaml
on:
   push:
      branches:
         - v1-support
jobs:
   Release:
      runs-on: ubuntu-latest
      permissions:
         contents: write
      steps:
         - name: Checkout
           uses: actions/checkout@v4
           with:
              fetch-depth: 0

         - name: Release
           uses: agilecustoms/release@main
           with:
               tag-context: branch
```
Note: tag `latest` is only added to default (typically `main`) branch,
so if you release new `#patch` version in "support" branch w/ and most recent tag is "1.2.3",
then new tag will be `1.2.4` plus tags `1`, `1.2` will be overwritten to point to the same commit as `1.2.4`, but `latest` tag will not be changed

### specify version explicitly
TBD

### dev release
TBD

### custom-version-update
TBD

## Roadmap
- support explicit version as input parameter
- support push in non-main branch
- support `on: pull_request` event
- multi-region support

## Testing (work in progress)
1. Make a branch 'feature' (this repo unlikely to incur many changes)
2. Push branch and get feedback
3. Once satisfied, revert any debug changes and merge to `main`

## Credits
- https://github.com/anothrNick/github-tag-action
