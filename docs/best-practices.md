# Best practices

- [Build and Release](#build-and-release)
- [conventional commits](#conventional-commits)
- [Company-specific gha-release wrapper](#company-specific-gha-release-wrapper)

## Build and Release

In all my projects and all [examples](./examples) I use two workflows: Build and Release.
Sometimes when there is nothing to build, I call it Validate instead of Build, [example](https://github.com/agilecustoms/terraform-aws-ci-publisher/blob/main/.github/workflows/validate.yml)

Build is called on every push in non-main branches. It runs all quality checks such as linters and tests.
At this point Build workflow does not produce any artifacts, it just tells you if your code is good or not.
Once it is good, you typically create a PR and get approvals

Upon PR merge, the Release workflow is triggered (it is configured to run on push in `main` branch).
Then Release workflow calls Build workflow again, this time intent is to get artifacts!

These are typical setup for these two workflows:

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
        uses: actions/checkout@v4

      # Setup tools
      # Install dependencies
      # Run linting and tests

      # Build/Package the artifact(s)

      - name: Upload artifacts
        if: inputs.artifacts # no sense to upload artifacts on every push in a feature branch
        uses: actions/upload-artifact@v4
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
    environment: release # hold `GH_TOKEN` secret, available only for `main` branch
    permissions:
      contents: read # required for checkout
      id-token: write # not always required, only if at some step you assume AWS role via OIDC
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Download artifacts
        uses: actions/download-artifact@v4

      - name: Release
        uses: agilecustoms/release@v1
        with: # parameters specific to artifact type(s) being released 
        env:
          GH_TOKEN: ${{ secrets.GH_TOKEN }} # required to push commit and tags
```

## conventional commits

`agilecustoms/release` uses [semantic-release](https://github.com/semantic-release/semantic-release)
for next version generation. semantic-release has several presets for different commit message conventions.
Default preset is "angular", but in all my projects I use "conventionalcommits" preset in `.releaserc.json`:

```json
{
  "branches": { ... },
  "plugins": [
    [
      "@semantic-release/commit-analyzer",
      {
        "preset": "conventionalcommits",
        "releaseRules": [ ... ]
      }
    ],
    [
      "@semantic-release/release-notes-generator",
      {
        "preset": "conventionalcommits",
        "presetConfig": { ... }
      }
    ]
  ]
}
```

Non-default presets require additional npm dependency. This is why in many examples you may see 
`npm-extra-deps` input, like [here](https://github.com/agilecustoms/terraform-aws-ci-builder/blob/main/.github/workflows/release.yml)

```yaml
- name: Release
  uses: agilecustoms/release@v1
  with:
    npm-extra-deps: conventional-changelog-conventionalcommits@9.1.0
``` 

For more details see [semantic commits](./features/semantic-commits.md) 

## Company-specific gha-release wrapper

TBD
