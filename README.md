# About
Reusable GitHub Action `gha-release`
1. Generate new version
   1. use input.version if provided
   2. else: generate version based on the latest tag + git commit message: #major, #minor, #patch
2. Update version in code (`package.json`, `pom.xml`) and commit
   1. maven (java-parent)
   2. npm (envctl)
   3. custom (envctl to update cache key!)
3. Git push
   1. push two tags: new (generated) version and 'latest'
   2. push changes from step 2
4. Publish artifacts
   1. S3 (tt-message, tt-web, tt-auth, db-evolution-runner, env-api). Files need to be in `s3` directory. Supports dev-release
   2. Docker - ECR (env-cleanup)
   3. maven - CodeArtifact (java-parent)
   4. npm - npmjs.com (envctl)

Note: first I do git "Git push" and then "Publish artifacts", so that if publish fails, I can re-run release workflow.
Of course, the price is dangling git tag. If publish fails painfully, we can easily roll back git tag!

## Test via 'test' workflow
1. Make a branch 'feature' (this repo unlikely to incur many changes)
2. Push branch and get feedback
3. Once satisfied, revert any debug changes and merge to `main` 

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
           uses: agilecustoms/gha-release@main
```
Note: adding/overwriting tags requires GH job permissions `content: write`

### publish in S3
Convention: there should be `s3` directory in cwd. All content of this directory will be uploaded in S3 bucket<br>
Ex: if current tag is '1.2.3' and commit has #patch, then files will be uploaded to `s3-bucket/s3-bucket-dir/1.2.4`
Also files will be uploaded in dirs `/1`, `/1.2` and `/latest` - previous content of these dirs will be cleaned up
```yaml
steps:
  - name: Release
    uses: agilecustoms/gha-release@main
    with:
      aws-account: ${{ vars.AWS_ACCOUNT_DIST }}
      aws-region: us-east-1
      aws-role: 'ci/publisher' # default
      s3-bucket: '{company-name}-dist' # recommended, no default
      s3-bucket-dir: '' # empty by default
```
Note: `s3-bucket-dir` is empty by default, so files will be uploaded to `s3-bucket/{current-repo-name}/1.2.4`.<br>
Note: If you have `./s3` directory, but miss one of required variables, the action will fail with descriptive error message.<br>

### publish in ECR
TBD

### publish in CodeArtifact
TBD

### publish in npm
TBD



## Additional use cases

### release from non-main branch
Assume main development (v2.x) is conducted in 'main' branch, while version 1.x is maintained in 'v1-support' branch.
If you want to make release in support branch, you need
1. run actions/checkout with with 'fetch-depth: 0'
2. pass parameter 'tag-context: branch'
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
           id: release
           uses: agilecustoms/gha-release@main
           with:
               tag-context: branch
```

### specify version explicitly
TBD

### dev release
TBD

### custom-version-update
TBD

## Future
- multi-region support