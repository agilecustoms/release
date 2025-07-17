# GitHub Authorization


1. (main scenario) you merge a PR in a protected branch, and this release assumes an automated commit (such as update CHANGELOG.md)
   → you need a PAT (Personal Access Token) with `repo` scope or fine-grained PAT with `Contents "Read and write"`

Below is a simple breakdown. For more details see [GitHub authorization](./docs/github-auth.md).
2.
**Main use case**: you have branch `main` with protection rules
Merged PR in `main` branch, branch has protection rules that require PR reviews, and you want to release it:
release commit bypassing rule protection (update package.json, pom.xml or CHANGELOG.md)
or release-gh: true
-> need a fine-grained PAT with `Contents "Read and write"` or classic PAT with `repo` scope.
Can checkout with this token or call `agilecustoms/publish` with env variable `GH_TOKEN`

release-gh: false, changelog-file: '' (no changelog), no libraries to publish, just git tag. Example: ECR image, S3 files, Terraform module
-> PAT is not required, just ensure GH job has `permissions: contents: write` (to push tags)

if not even pushing tags, PAT is not required and even job permissions can be `contents: read`

dev-release: true
PAT is not required
GH_TOKEN: ${{ github.token }}