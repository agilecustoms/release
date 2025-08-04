### publish in AWS CodeArtifact Maven repository

This action publishes maven artifacts in AWS CodeArtifact repository.
Note: it doesn't compile source code, nor run tests, it just updates a version in `pom.xml` and publishes it.
So put your maven "heavy lifting" (compile, test, package) prior to this action.
See .. for details how to set up settings.xml, pom.xml and how to use artifacts published by this action.
```yaml
steps:
  - name: Release
    uses: agilecustoms/release@v1
    with:
      aws-account: ${{ vars.AWS_ACCOUNT_DIST }}
      aws-region: us-east-1
      aws-role: 'ci/publisher'
      aws-codeartifact-maven: true
```
**dev-release** works is nothing else than just a normal release, but instead of semver `<version>1.2.4</version>`
you'll get `<version>{branch-name}</version>`. Particularly, there is no way to automatically delete such "dev versions".
Such versions will live in CodeArtifact repository forever until you delete them