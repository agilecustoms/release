# Best practices

- [Build and Release](#build-and-release)
- [Conventional commits](#conventional-commits)
- [Company-specific gha-release wrapper](#company-specific-gha-release-wrapper)

## Build and Release

Build and Release are two distinct actions. Build should happen on each push in a feature branch
for early feedback about code quality (lint, tests). Once code is merged into `main` branch there should be Build (again!) and Release.
There are two ways how you can organize your workflows:
1. (simple) you have one workflow with two jobs: Build and Release.
 Build is run all the time, and a Release job is conditioned to run only on `main` branch
2. (advanced) you have two workflows: Build and Release. Build workflow is called on every push in non-main branches, 
 and also it can be called from another workflow (`on: workflow_call:`).
 Release workflow is called only on push in the `main` branch, and inside it calls Build workflow
 Advanced setup is used when there are multiple types of releases: besides normal (when feature is merged into `main` branch)
 there are [dev-release](./features/dev-release.md) and "fixed version" when a version is passed explicitly as workflow argument:
```
      /- normal release
build -- dev release
      \- fixed version release
```
3. (Docker specific) GitHub uses two actions: `actions/upload-artifact` and `actions/download-artifact` to pass files
 between jobs. If you place `docker build` command in Build job - you can't access it in Release.
 So the only way is to place `docker build` in a Release job. Finally, if you have multiple release options,
 you end up with a workflow layout like this [example](./examples/env-cleanup):
```
                 /- normal release
build -- release -- dev release
                 \- fixed version release
```

Below is an example of advanced setup (two workflows):

`build.yml`
```yaml
name: Build

on:
  push:
    branches-ignore:
      - main

  workflow_call: # Allow to call this workflow from Release workflow
    inputs:
      artifacts:
        required: false
        type: boolean
        default: false
        description: upload artifacts or not

jobs:
  Build:
    runs-on: ubuntu-latest
    permissions:
      contents: read # required for checkout
      id-token: write # not always required, only if at some step you assume AWS role via OIDC
    steps:
      - name: Checkout code
        uses: actions/checkout@v6

      # Setup tools
      # Install dependencies
      # Run linting and tests

      # Build/Package the artifact(s)

      - name: Upload artifacts
        if: inputs.artifacts # no point in uploading artifacts on every push in a feature branch
        uses: actions/upload-artifact@v6
        with: # configure what to upload
```

`release.yml`
```yaml
name: Release

on:
  push:
    branches:
      - main

jobs:
  Build:
    uses: ./.github/workflows/build.yml
    with:
      artifacts: true # for release purposes we want artifacts
    secrets: inherit
    permissions: # specify same permissions as in Build workflow
      contents: read
      id-token: write

  Release:
    needs: Build
    runs-on: ubuntu-latest
    environment: release # holds the `GH_TOKEN` secret, available only for `main` branch
    permissions:
      contents: read # required for checkout
      id-token: write # not always required, only if at some step you assume AWS role via OIDC
    steps:
      - name: Checkout
        uses: actions/checkout@v6

      - name: Download artifacts
        uses: actions/download-artifact@v7
        with:
          path: # where to download artifact(s)

      - name: Release
        uses: agilecustoms/release@v4
        with: # parameters specific to artifact type(s) being released 
        env:
          GH_TOKEN: ${{ secrets.GH_TOKEN }} # required to push commit and tags
```

## Company-specific gha-release wrapper

In many [examples](./examples) you may some inputs repeat, such as `aws-account`, `aws-region`, `aws-role`.
You can reduce code repetition by creating your own wrapper around `agilecustoms/release`.
For this just create a new GH repo with single file `action.yml`, see example [gha-release](./examples/gha-release).
Here you provide company-specific defaults, see comment `# company-specific defaults`.
For parameters that may vary - you add them in `inputs` section and pass them through, see comment `# pass through inputs`.
For pass-through inputs you can use either same defaults as in `agilecustoms/release` (like `floating-tags` default is true)
and for others you may want to set your own defaults (like `summary`).

Especially useful to provide default value for input `release-plugins`.
This is the recommended way to have shared release configuration among multiple repos.
Alternative is to have `.releaserc.json` file in each repo, but then you need to maintain it in multiple places.
See [configuration](./configuration.md) for more details on configuration options.

Security note. In "dev-release" mode the `aws-role` is set to `ci/publisher-dev` which has limited permissions,
see [dev-release security](./authorization.md#dev-release-security) for details

Tech note. Once you create your custom GH action wrapper, make sure other repos can access it.
For this go to your repo Settings > Actions > General > "Workflow permissions" > "Access" >
set "Accessible from repositories in the '_mycompany_' organization"
