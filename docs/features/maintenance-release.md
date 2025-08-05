## Maintenance release

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


Consider a repo with current version `2.x.x` in `main` branch and `1.x.x` with legacy version support.
You need to place a file `.releaserc.json` in the repo root with the following content:
```json
{
  "branches": [
    "main",
    "1.x.x"
  ]
}
```
And also make sure your release workflow (e.g. `.github/workflows/release.yaml`) is triggered on `1.x.x` branch as well:
```yaml
on:
  push:
    branches:
      - main
      - 1.x.x
```

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
Read about maintenance branches in [semantic-release documentation](https://semantic-release.gitbook.io/semantic-release/usage/workflow-configuration#maintenance-branches)
