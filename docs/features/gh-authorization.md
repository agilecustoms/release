# GitHub Authorization

There are 2 main use cases: release from protected branch and dev-release

## Release from protected branch

Typical GitHub repo has protected branch such as `main` which requires all changes to be made via PRs.
At the same time, release workflow often assumes some automated changes, such as bump version in `package.json` or update `CHANGELOG.md`.
In this setup you need to **bypass** branch protection rule to make direct commit and push

This requires a PAT ([Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)) issued by a person who has permission to bypass the branch protection rules
- either a fine-grained PAT with `Contents "Read and write"`
- or classic PAT with `repo` scope

This is also true for maintenance branches and prerelease branches

```yaml
jobs:
   Release:
      runs-on: ubuntu-latest
      permissions: # required only to publish artifacts in AWS
         id-token: write
         contents: read
      steps:
         - name: Checkout
           uses: actions/checkout@v4

         # ...

         - name: Release
           uses: agilecustoms/release@v1
           env:
              GH_TOKEN: ${{ secrets.GH_TOKEN }} # PAT to bypass branch protection (from repo/org secret GH_TOKEN)
```

Notes:
- `permissions` section is required if you release software artifacts in AWS (S3, ECR, CodeArtifact), see [aws-authorization](./aws-authorization.md) for details
- secret name could be different, I use `GH_TOKEN` for consistency with env variable
- if you have no automated code changes (no `package.json`, no `pom.xml`, etc. the `CHANGELOG.md` update is disabled),
then PAT is not required, just ensure a job has `permissions: contents: write` (to push tags).
Examples: ECR image, S3 files, Terraform module

Next you have a choice **how to pass this PAT**:

Option 1 (recommended): pass PAT in `agilecustoms/release` env variable `GH_TOKEN`
```yaml
- name: Release
  uses: agilecustoms/release@v1
  env:
     GH_TOKEN: ${{ secrets.GH_TOKEN }}
```

Option 2: pass PAT in `github/checkout` `token` parameter
```yaml
- name: Checkout
  uses: actions/checkout@v4
  with:
    token: ${{ secrets.GH_TOKEN }}
```

You must use Option 1 to make a GH release (input `release-gh` is `true` by default).
If not use GH releases, you can choose Option 1 or 2, but Option 1 is still recommended —
it limits write access only to one step (`agilecustoms/release`).
In Option 2 all steps (after checkout) effectively have permission to commit and push in protected branch

## dev-release

Dev-release does not require PAT because it does not need to make a direct push in the protected branch

```yaml
jobs:
  Release:
    runs-on: ubuntu-latest
    permissions: # required only to publish artifacts in AWS
      id-token: write
      contents: write
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      # ...

      - name: Release
        uses: agilecustoms/gha-release@main
        with:
          dev-release: true
```
