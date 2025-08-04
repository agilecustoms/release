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
