# Maintenance release

Maintenance release is a release from a branch with a version range.
A range can be reflected in branch name like `N.x.x` or `N.N.x` (where `N` is a number)
OR branch may have an arbitrary name but assigned range.
In both cases, the maintenance branch needs to be explicitly configured.
Configuration can be provided in `.releaserc.json` file (preferred) or via `release-branches` input

Additionally, make sure your release workflow (e.g. `.github/workflows/release.yaml`)
is triggered on this maintenance branch (use `1.x.x` for example):
```yaml
on:
  push:
    branches:
      - main
      - 1.x.x
```

## Example 1. Branch 1.x.x

Imagine current development in `main` branch and previous version in `1.x.x` branch,
and you use [semantic commits](./semantic-commits.md) or [version bump](./version-generation.md#version-bump)

You need to place a file `.releaserc.json` in the repo root with the following content:
```json
{
  "branches": [
    "main",
    "1.x.x"
  ]
}
```

This will allow to release versions in range `1.0.0 <= .. < 2.0.0` from `1.x.x` branch

## Example 2. Branch with assigned range

For **non-standard** maintenance branch name, like `support`, you need following `.releaserc.json`:
```json
{
  "branches": [
    "main",
    {
      "name": "support",
      "range": "1.x.x"
    }
  ]
}
```

## Example 3. Release channels

In this example we have "patch" maintenance branch `1.5.x` with versions in range `1.5.0 <= .. < 1.6.0`.
And it has a release channel `legacy`, so that git tag `legacy` moves on every release. See [floating tags](./floating-tags.md) for details
```json
{
  "branches": [
    "main",
    {
      "name": "1.5.x",
      "channel": "legacy"
    }
  ]
}
```

Read more about maintenance branches in [semantic-release documentation](https://semantic-release.gitbook.io/semantic-release/usage/workflow-configuration#maintenance-branches)
