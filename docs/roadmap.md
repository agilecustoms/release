# Roadmap

Next:
- GitHub action to access terraform modules from corporate private GH repos
- publish in Maven central
- publish in AWS CodeArtifact. Every artifact type will require a corresponding GH action like [setup-maven-codeartifact](https://github.com/agilecustoms/setup-maven-codeartifact)
  - Python packages (pip and Twine)
  - npm
  - Gradle
- input `version-bump` to take two more options: `minor` and `patch`. Requires custom conventional-commits config with custom minor/patch triggers to "ignore" accidental `fix:`, `feat:` and `BREAKING CHANGE:` commits
- ensure `release-channel` is respected together with conventional commits and `version-bump`
- customizable publish path (S3 path, ECR repository): renaming a repo should not break existing artifacts in S3/ECR
- publish artifacts in GitHub release
- clear error message for malformed configuration
- test `npm-visibility: private`
- bring actual errors (from release-gen) in [troubleshooting](./troubleshooting.md)
- [terraform-aws-ci-builder](https://github.com/agilecustoms/terraform-aws-ci-builder): ECR access, to build one Docker image from another one

Potential future features (not prioritized):
- publish in AWS CodeArtifact: Yarn
- publish in non-AWS repositories
  - private npmjs repository
- GitHub release
  - ability to specify a list of files to include release
  - integration between release and issues/PRs, ex: close issues fixed in a release, see [semantic-release/github](https://github.com/semantic-release/github)
  - notify maintainers and users about new releases
- support proxy on different levels (just never faced with it yet)
- git commit
  - ability to customize the commit message, see [semantic-release/git](https://github.com/semantic-release/git)
  - GPG signing
- features from downstream/related actions
  - semantic-release: `working_directory`, `repository_url` and `dry-run` mode like in [semantic-release-action](https://github.com/cycjimmy/semantic-release-action?tab=readme-ov-file#inputs)
  - more outputs like in [semantic-release-action](https://github.com/cycjimmy/semantic-release-action?tab=readme-ov-file#outputs)
  - `actions/setup-java` has lots of [extra inputs](https://github.com/actions/setup-java?tab=readme-ov-file#usage)
  - `aws-actions/configure-aws-credentials` has lots of [extra inputs](https://github.com/aws-actions/configure-aws-credentials?tab=readme-ov-file#options)
  - inputs `registries`, `registry-type`, `http-proxy` from [amazon-ecr-login](https://github.com/aws-actions/amazon-ecr-login/tree/main)
