# GitHub Authorization

There are 2 main use cases: release from protected branch and dev-release

## Release from protected branch

Typical GitHub repo has protected branch such as `main` which requires all changes to be made via PRs.
At the same time, release workflow often assumes some automated changes, such as bump version in `package.json` or update `CHANGELOG.md`.
In this setup you need to **bypass** branch protection rule to make direct commit and push

This requires a PAT ([Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)) issued by a person who has permission to bypass the branch protection rules.
- either a fine-grained PAT ([Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)) with `Contents "Read and write"`
- or classic PAT with `repo` scope

This is also true for maintenance branches and prerelease branches

```yaml
jobs:
   Release:
      runs-on: ubuntu-latest
      permissions:
         id-token: write # need for AWS login (via GitHub OIDC provider)
         contents: read # since `id-token` is specified, need to explicitly set `contents` permission for checkout
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
- `id-token: write` is to log in AWS ([details](./aws-authorization.md)), required to release artifact in any of S3, ECR, CodeArtifact
- `contents: read` seem to be obvious. it is set by default, but when you set `id-token: ..` - you loose the default and now it needs to be set explicitly 
- secret name could be different, I use `GH_TOKEN` for consistency with env variable

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

Dev-release does not require PAT, bcz it does not need to make direct push in protected branch.
Same as release from protected branch, it requires `permissions` `id-token: write` to login in AWS (if needed).

```yaml
jobs:
  DevRelease:
    runs-on: ubuntu-latest
    permissions:
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

## advanced

**contents: write**

_When: protected branch, but not automated commit required, just push git tags and/or github release_<br>
_When: non-protected branch + automated changes and git commit/push_

release-gh: false, changelog-file: '' (no changelog), no libraries to publish, just git tag. Example: ECR image, S3 files, Terraform module
-> PAT is not required, just ensure GH job has `permissions: contents: write` (to push tags)

**contents: read**

_When: no git changes, not even tags_

if not even pushing tags, PAT is not required and even job permissions can be `contents: read`

dev-release: true
PAT is not required
GH_TOKEN: ${{ github.token }}
