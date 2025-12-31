# publish in npmjs

**As of Aug 2025 only public npmjs repositories are supported (private is available, but not tested!)**

_Note: all examples use shared patterns: two workflows: Build and Release — covered in [Best practices](../best-practices.md);
"release" GitHub environment — covered in [Authorization and security](../authorization.md)_

## Public NPM package

Example: [envctl](../examples/envctl) — it is from the AgileCustoms repository with all code removed, only workflows left.
GitHub repository is private but published as public NPM package `@agilecustoms/envctl`

```
<repo root>
├── .github/
├── dist/           <-- _NOT_ stored in git
│   └── ...         <-- compiled .js files
├── src/
│   ├── ...
│   └── index.ts
├── action.yml
├── package.json
└── tsconfig.json
```

Also, this repository is a GH action. It acts as a wrapper for npm cli app, thus file `action.yml`.
`envctl` is an NPM package, not "all-in-one" JS file, so installation assumes pulling all dependencies.
To make it faster, I use cache in `action.yml` file:

```yaml
- name: Cache global npm
  uses: actions/cache@v5
  with:
    path: ~/.npm
    key: npm-global-${{ runner.os }}-envctl-cache-key-0.23.13
```

Cache needs to be updated on every release, so I use `pre-publish-script` to update version in `action.yml` file

```yaml
jobs:
  # ...
  Release:
    needs: Build
    # ...
    steps:
      # ...
      - name: Download artifacts
        uses: actions/download-artifact@v5
        with:
          path: dist

      - name: Release
        uses: agilecustoms/release@main
        with:
          pre-publish-script: sed -i -E "s/(envctl-cache-key-)[^\n]+/\1$version/" "action.yml"
        env:
          GH_TOKEN: ${{ secrets.GH_TOKEN }} # to push changes in GH repo
          NPM_TOKEN: ${{ secrets.NPMJS_TOKEN }} # to publish in npmjs
```

When a developer merges a PR, the Release workflow is triggered:
1. Build and Release can be organized as two jobs in the same workflow or as two separate workflows, see [Best practices](../best-practices.md#Build-and-Release)
2. Build job compiles TypeScript in JavaScript in directory `dist` and uploads entire `dist` as an artifact
3. Release job downloads the artifact and calls `agilecustoms/release` action, then action:
   1. generate the next version based on commit messages
   2. call `pre-publish-script` with this version to update cache key in `action.yml`
   3. update version in `package.json`
   4. run `npm publish` to publish package in npmjs using `NPM_TOKEN`
   5. push commit and tags to the remote repository
