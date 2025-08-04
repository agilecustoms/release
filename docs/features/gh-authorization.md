# GitHub Authorization

Most of the time GitHub repos have protected branch such as `main` which requires to be made only via PRs.
At the same time, release workflow often assumes some automated changes, such as bump versions `package.json` or update `CHANGELOG.md`.
In this setup you need to **bypass** branch protection rule to make direct commit and push.
This requires a PAT ([Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)) issued by a person who has permission to bypass these branch protection rules.
So this is the main use case for `agilecustoms/release` action. For more details see [GitHub authorization](./docs/gh-authorization.md)

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
           uses: agilecustoms/release@v1
           env:
              GH_TOKEN: ${{ secrets.GH_TOKEN }} # PAT to bypass branch protection. Create PAT and put it in repo/org secrets
```

In the main README you could see a usage example for the main usecase. 
Let's cover in details when and what kind of GitHub authorization is required.
There will be three sections from highest access to lowest access.

## PAT required

_When: protected branch + automated changes and git commit/push_

1. You merge a PR in a protected branch such as `main`/`master`, branch for next release or legacy version support
2. Release includes automated changes that need to be committed and pushed, such as:
   1. bump a version in language-specific files such as `package.json` (Node.js), `pom.xml` (Java)
   2. update CHANGELOG.md
   3. any other files you can update with `pre-publish-script`

→ need a fine-grained PAT ([Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens))
with `Contents "Read and write"` or classic PAT with `repo` scope

Next you have a choice **how to pass this PAT**:

Option 1 (recommended): pass PAT in `agilecustoms/release` env variable `GH_TOKEN`
```yaml
- name: Release
  uses: agilecustoms/release@v1
  env:
     GH_TOKEN: ${{ secrets.GH_TOKEN }}
```
You must use this option to make a GH release (input `release-gh` is true by default).
If not use GH releases, you can choose Option 1 or 2, but Option 1 is still recommended —
this way you limit write access only to one step (`agilecustoms/release`), while other job steps have readonly access

Option 2: pass PAT in `github/checkout` `token` parameter
```yaml
- name: Checkout
  uses: actions/checkout@v4
  with:
    token: ${{ secrets.GH_TOKEN }}
```

_secret name could be different, I use `GH_TOKEN` for consistency with env variable_

## contents: write

_When: protected branch, but not automated commit required, just push git tags and/or github release_<br>
_When: non-protected branch + automated changes and git commit/push_

release-gh: false, changelog-file: '' (no changelog), no libraries to publish, just git tag. Example: ECR image, S3 files, Terraform module
-> PAT is not required, just ensure GH job has `permissions: contents: write` (to push tags)

## contents: read

_When: no git changes, not even tags_

if not even pushing tags, PAT is not required and even job permissions can be `contents: read`

dev-release: true
PAT is not required
GH_TOKEN: ${{ github.token }}