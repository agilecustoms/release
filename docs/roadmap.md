# Roadmap

Below is the list of potential future features, but it is not ordered. Idea is to implement them as needed

- publish in AWS CodeArtifact
  - npm (and Yarn) repository
  - pip (and Twine) repository
  - **Gradle repository**
- publish in non-AWS repositories
  - private npmjs repository
  - **Maven central**
- GitHub release
  - ability to specify a list of files to include release. Should be pretty easy — just add parameter in `gh release create` command
  - integration between release and issues/PRs, ex: close issues fixed in a release, see [semantic-release/github](https://github.com/semantic-release/github)
  - **prereleases**
  - notify maintainers and users of new releases
- support proxy on different levels (just never faced with it yet)
- git commit
  - ability to customize the commit message, see [semantic-release/git](https://github.com/semantic-release/git)
  - GPG signing

