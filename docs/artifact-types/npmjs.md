### publish in public npmjs repo

Publish in *a public* npmjs repository. Contribute to support private npmjs repositories if needed.
This will generate new version, update a version in `package.json`, commit, push commit + tags and publish in npmjs.com
```yaml
steps:
  - name: Release
    uses: agilecustoms/release@v1
    env:
      NPM_PUBLIC_TOKEN: ${{ secrets.NPMJS_TOKEN }}
```

**dev-release** assumes you publish a version named after the branch name, but npm only supports semantic versioning.
Best alternative is to publish a specific version say latest is `1.2.3` and you publish `1.2.3-test`
