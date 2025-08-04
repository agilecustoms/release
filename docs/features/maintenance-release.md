## Maintenance release

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
