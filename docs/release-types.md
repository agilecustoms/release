# Release types

Difference between **prerelease** and **dev-release**:

_prerelease_ is an industry standard, though some tools use different terms
like "prerelease" (GitHub), distribution tags (npm), suffix "-SNAPSHOT" (maven), suffixes "-beta", "rc" (Gradle, NuGet, PyPI, pip).
Idea: release version widely available for testing and potential to become a final release

_dev-release_ is just a way to overcome inability to spin up entire env locally.
So you have your feature branch and want to deploy it in sandbox or dev environment for dev testing or POC

Imagine a team of developers working on a prerelease 2.0.0-alfa based off the branch 'next'.
Each developer (rarely two) creates a feature branch. And then, if this feature requires testing in cloud,
the developer may decide to create a dev-release based off the branch name (`dev-feature1`), then test it and merge to 'next' branch

The table below shows comparison of different release types:

| Name                                             | release                                                 | prerelease                                      | dev-release                                                |
|--------------------------------------------------|---------------------------------------------------------|-------------------------------------------------|------------------------------------------------------------|
| intention                                        | use in production                                       | beta testing                                    | dev testing                                                |
| best use for                                     | software packages and end applications                  | software packages and end applications          | end applications                                           |
| adoption                                         | widely                                                  | widely                                          | popular in enterprise                                      |
| versioning                                       | semantic-release used to determine next version         | semantic-release used to determine next version | version = branch name, override on each push, no increment |
| auto deletion                                    | N/A                                                     | ❌️                                              | ✅                                                          |
| number of developers                             | many                                                    | many                                            | typically one                                              |
| release notes and changelog                      | ✅                                                       | ✅                                               | ❌️                                                         |
| floating tags                                    | major, major.minor, latest                              | ?                                               | ❌️                                                         |
| semantic tags `fix:`, `feat:` in commit messages | at least one commit w/ such tag is required for release | at least one commit w/ such tag is required     | not required                                               |

### Dev release

Dev release allows publishing artifacts temporarily for testing purposes:
you push your changes to the feature branch, branch name becomes this dev-release version:
- semver is _not_ generated
- no git tags created — your branch name is all you need
- if branch name is `dev/feature` then the version will be `dev-feature`
- parameter `dev-branch-prefix` (default value is `dev/`) enforces branch naming for dev releases, it helps to automatically dispose dev-release artifacts. Set to empty string to disable such enforcement
- for each artifact type, dev-release might have different semantics, see `dev-release` section for each artifact type

Example of 'dev-release' usage with AWS S3:
```yaml
steps:
  - name: Release
    uses: agilecustoms/release@v1
    with:
      aws-account: ${{ vars.AWS_ACCOUNT_DIST }}
      aws-region: us-east-1
      aws-role: 'ci/publisher' # default
      aws-s3-bucket: 'mycompany-dist'
      dev-release: true
      dev-release-prefix: 'dev/' # default
```