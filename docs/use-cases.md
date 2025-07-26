# Use cases

- [Publish in AWS](#publish-in-aws)
  - [Publish in AWS S3](#publish-in-aws-s3)
  - [Publish in AWS ECR](#publish-in-aws-ecr)
  - [Publish in AWS CodeArtifact Maven repository](#publish-in-aws-codeartifact-maven-repository)
- [Non-AWS](#non-aws)
  - [Publish in public npmjs repo](#publish-in-public-npmjs-repo)
  - [No artifacts (git tags + GH release)](#no-artifacts-git-tags--gh-release)
  - [Release terraform module](#release-terraform-module)
  - [Release TypeScript GH Action](#release-typescript-gh-action)
- [Additional use cases](#additional-use-cases)
  - [Release from non-main branch](#release-from-non-main-branch)
  - [Explicit version](#explicit-version)

## Publish in AWS 

1. Pick an AWS account for publishing artifacts, place it in org variable `AWS_ACCOUNT_DIST`
2. Create S3 bucket to publish raw artifacts, ECR repository for Docker images, CodeArtifact for software packages
3. Create an IAM role (ex. `ci/publisher`) with respective permissions: `s3:PutObject`, `ecr:PutImage`, `codeartifact:PublishPackageVersion` etc.
   See example terraform module [terraform-aws-ci-publisher](https://github.com/agilecustoms/terraform-aws-ci-publisher)

### publish in AWS S3

Convention: there should be `s3` directory in cwd. All content of this directory will be uploaded in S3 bucket<br>
Ex: if the latest tag is '1.2.3' and single commit on top of it `fix: JIRA-123`, then files will be uploaded to `aws-s3-bucket/aws-s3-bucket-dir/1.2.4`
Also files will be uploaded in dirs `/1`, `/1.2` and `/latest` - previous content of these dirs will be cleaned up
```yaml
steps:
  - name: Release
    uses: agilecustoms/release@v1
    with:
      aws-account: ${{ vars.AWS_ACCOUNT_DIST }}
      aws-region: us-east-1
      aws-role: 'ci/publisher' # default
      aws-s3-bucket: 'mycompany-dist'
```
Additionally, you can specify `aws-s3-dir`, then files will be uploaded to `s3-bucket/{aws-s3-dir}/{current-repo-name}/{version}/{files from ./s3 directory}`<br>
Convention: publishing of all AWS types of artifacts require `aws-account`, `aws-region` and `aws-role` parameters

**dev-release** will publish files in `s3-bucket/{aws-s3-dir}/{current-repo-name}/{branch-name}/` directory.
Each S3 file will be tagged with `Release=false`, so you can set up lifecycle rule to delete such files after 30 days!


### publish in AWS ECR

First you build docker image, and then you release it with this action.
Same as git tags, when you release version `1.2.3` with commit message `fix: JIRA-123`,
new docker image will be tagged as `1.2.4`, and tags `1`, `1.2` and `latest` will be overwritten to point to the same image as `1.2.4`
```yaml
steps:
  - name: Docker build
    run: docker build

  - name: Release
    uses: agilecustoms/release@v1
    with:
      aws-account: ${{ vars.AWS_ACCOUNT_DIST }}
      aws-region: us-east-1
      aws-role: 'ci/publisher'
      aws-ecr: true
```

**dev-release** works smoothly with ECR: Docker image gets published with tag equal to branch name.
ECR allows you to configure lifecycle rules by tag prefix, so if you adopt `dev/` prefix for your dev-release branches,
then you can set up ECR lifecycle rule to delete images with prefix `dev-` after 30 days automatically!

### publish in AWS CodeArtifact Maven repository

This action publishes maven artifacts in AWS CodeArtifact repository.
Note: it doesn't compile source code, nor run tests, it just updates a version in `pom.xml` and publishes it.
So put your maven "heavy lifting" (compile, test, package) prior to this action.
See .. for details how to set up settings.xml, pom.xml and how to use artifacts published by this action.
```yaml
steps:
  - name: Release
    uses: agilecustoms/release@v1
    with:
      aws-account: ${{ vars.AWS_ACCOUNT_DIST }}
      aws-region: us-east-1
      aws-role: 'ci/publisher'
      aws-codeartifact-maven: true
```
**dev-release** works is nothing else than just a normal release, but instead of semver `<version>1.2.4</version>`
you'll get `<version>{branch-name}</version>`. Particularly, there is no way to automatically delete such "dev versions".
Such versions will live in CodeArtifact repository forever until you delete them


## Non-AWS artifact stores

### publish in public npmjs repo

Publish in *public* npmjs repository. Contribute to support private npmjs repositories if needed.
This will generate new version, update version in `package.json`, commit, push commit + tags and publish in npmjs.com
```yaml
steps:
  - name: Release
    uses: agilecustoms/release@v1
    env:
      NPM_PUBLIC_TOKEN: ${{ secrets.NPMJS_TOKEN }}
```
**dev-release** assumes you publish a version named after branch name, but npm only supports semantic versioning.
Best alternative is to publish a specific version say latest is `1.2.3` and you publish `1.2.3-test`


### No artifacts (git tags + GH release)

For example, for a repository with terraform code only - no binaries, just add git tag.
Version will be automatically generated based on the latest version tag + commit messages.
Ex: if the latest tag is `1.2.3` and there is a single commit `fix: JIRA-123`, then the new tag will be `1.2.4`.
Also tags `1`, `1.2` and `latest` will be overwritten to point to the same commit as `1.2.4`

Adding/overwriting tags write access. It can be done in two ways:

**Use default GitHub token** (note permissions `contents: write`):
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
        uses: agilecustoms/release@v1
        env:
           GH_TOKEN: ${{ github.token }} # == ${{ secrets.GITHUB_TOKEN }}, required for GitHub release
```

**Use PAT**. Default token has lots of permissions, so alternatively you can use PAT with explicit permissions:
```yaml
jobs:
  Release:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          persist-credentials: false

      - name: Release
        uses: agilecustoms/release@v1
        with:
          GH_TOKEN: ${{ secrets.MY_GH_TOKEN }} # your PAT 
```

### release terraform module

Terraform modules 1) use v prefix and 2) do not accept floating tags (`latest`, `1`, `1.2`)
```yaml
steps:
  - name: Release
    uses: agilecustoms/release@v1
    with:
      floating-tags: false
```

### release TypeScript GH Action

As of 2025 TypeScript is still often requiring transpilation to JavaScript, especially for GitHub Actions, which still use Node 20 as runtime.
So your GH Action repo looks like this:
```
<repo root>
├── dist
│   └── index.js <-- all .ts files transpiled and combined in this one
├── src
│   ├── FileService.ts
│   ├── FileUploader.ts
│   └── index.ts
├── action.yml
├── package.json
└── tsconfig.json
```
In this setup you make changes in .ts files and push changes in a branch. When PR is merged, the release workflow is triggered.
In release workflow your TS code is built again, and thus you have `dist/index.js` updated and needs to be committed and pushed.

```yaml
jobs:
  Release:
    runs-on: ubuntu-latest
    steps:
      # build TS code -> dist/index.js
      
      - name: Release
        uses: agilecustoms/release@v1
        env:
          GH_TOKEN: ${{ secrets.GH_PUBLIC_RELEASES_TOKEN }}
```

## Additional use cases

### release from non-main branch

Assume the main development (v2.x) is conducted in `main` branch, while version 1.x is maintained in `v1-support` branch.
If you want to make release in support branch, you need
1. run actions/checkout with with `fetch-depth: 0`
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
           uses: agilecustoms/release@v1
```
Note: tag `latest` is only added to default (typically `main`) branch,
so if you release new "patch" version in "support" branch w/ and most recent tag is "1.2.3",
then new tag will be `1.2.4` plus tags `1`, `1.2` will be overwritten to point to the same commit as `1.2.4`, but `latest` tag will not be changed

### explicit version

Use the `version` input parameter to specify an exact version instead of auto-generating one.
When provided, only this single version/tag will be created (no `latest`, `major`, or `minor` tags).
Typically, you use normal release flow (for trunk-based development) or `dev-release: true` to test some feature before merging it.

Use explicit **version** as last resort:
1. to fix an existing version in-place
2. instead of dev-release when it is not supported
