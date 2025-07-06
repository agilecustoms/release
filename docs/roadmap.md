# Roadmap
- publish in AWS CodeArtifact
  - npm (and Yarn) repository
  - pip (and Twine) repository
  - Gradle repository
- publish in private npmjs repository
- publish in Maven central
- GitHub release
  - ability to specify list of files to include release. Should be pretty easy - just add parameter in `gh release create` command
  - integration between release and issues/PRs, ex: close issues fixed in a release, see [semantic-release/github](https://github.com/semantic-release/github)
  - draft releases
- support proxy on different levels (just never faced with it yet)
- git commit
  - ability to customize commit message, see [semantic-release/git](https://github.com/semantic-release/git)
  - GPG signing

