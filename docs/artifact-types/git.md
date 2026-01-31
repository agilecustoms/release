# No artifacts, just git tags

Now days many types of software is released just as source code with version tag: Terraform modules, GitHub Actions, Go modules, etc.
This is the simplest scenario for `agilecustoms/release` as there is no need to publish any artifacts, just create a tag

_Note: all examples use shared patterns: two workflows: Build and Release — covered in [Best practices](../best-practices.md);
"release" GitHub environment — covered in [Authorization and security](../authorization.md)_

- [Terraform module](#terraform-module)
- [Composite GitHub Action](#composite-github-action)
- [Node.js GitHub Action](#nodejs-github-action)
- [dev-release](#dev-release)

## Terraform module

Example: [terraform-aws-ci-publisher](https://github.com/agilecustoms/terraform-aws-ci-builder)

[release.yml](https://github.com/agilecustoms/terraform-aws-ci-builder/blob/main/.github/workflows/release.yml)
```yaml
jobs:
  # ...
  Release:
    # ...
    steps:
      # ...
      - name: Release
        uses: agilecustoms/release@v4
        with:
          floating-tags: false
```
When publish in Terraform registry you can't use floating tags (`latest`, `1`, `1.2`).
For corporate terraform modules hosted in private GH repos you still can use floating tags

## Composite GitHub Action

Example: [setup-maven-codeartifact](https://github.com/agilecustoms/setup-maven-codeartifact)

[release.yml](https://github.com/agilecustoms/setup-maven-codeartifact/blob/main/.github/workflows/release.yml)
```yaml
jobs:
  Release:
    # ...
    steps:
      # ...
      - name: Release
        uses: agilecustoms/release@v4
```

## Node.js GitHub Action

Example: [publish-s3](https://github.com/agilecustoms/publish-s3)

```
<repo root>
├── .github
├── dist         <-- stored in git
│   └── index.js <-- all .ts files transpiled and combined in this one
├── src
│   ├── FileService.ts
│   ├── FileUploader.ts
│   └── index.ts
├── action.yml
├── package.json
└── tsconfig.json
```

This is a Node.js based GitHub Action written in TypeScript.
As of 2025 GitHub still doesn't natively support TypeScript, so transpilation is required.
Plus it is better to combine all source code in one file and minimize for quicker downloads.
This is all done by `ncc` compiler.

[release.yml](https://github.com/agilecustoms/publish-s3/blob/main/.github/workflows/release.yml)
```yaml
jobs:
  # ...
  Release:
    # ...
    steps:
      # ...
      - name: Download artifacts
        uses: actions/download-artifact@v7
        with:
          path: dist
        # after this we have changes in file dist/index.js

      - name: Release
        uses: agilecustoms/release@v4
```

When a developer merges a PR, the Release workflow is triggered:
1. Build and Release can be organized as two jobs in the same workflow or as two separate workflows, see [Best practices](../best-practices.md#Build-and-Release)
2. Build job compiles TypeScript files in a single `dist/index.js` file and uploads it as an artifact
3. Release job downloads the artifact and calls `agilecustoms/release` action, then action:
   1. commit `dist/index.js`
   2. push commit and tags to the remote repository

## dev-release

Git formally supports [dev-release](../features/dev-release.md). It just means you can create a feature branch
and run `agilecustoms/release` action in `dev-release` mode on this branch.
Git acts like glue for all other artifacts: branch `feature/login` becomes `feature-login` version.
IaC files such as Terraform are accessible via `?ref=feature/login`

Input `dev-branch-prefix` (default is `feature/`) enforces that only branches with this prefix
can run `agilecustoms/release` in dev-release mode.
This helps with [security](../features/dev-release.md#security) and auto cleanup
