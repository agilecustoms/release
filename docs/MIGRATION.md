# Migration Guide

## v5 -> v6

Version is now a bare semantic version (`1.2.3`), `tag-format` applies only to git tags (default `v${version}` -> `v1.2.3`).
Before, version was the same as git tag (`v1.2.3`) and it was used everywhere: S3 path, Docker tags, outputs.

- output `version` is bare: was `v1.2.3`, now `1.2.3`. Use new output `git-tag` if you need the git tag
- output `version-number` (added in v5.5.0) is removed, use `version` instead
- `pre-publish-script`: `$version` is bare `1.2.3`, `$version_number` is removed, use `$git_tag` for the git tag `v1.2.3`
- S3 dirs and Docker tags are bare: was `s3://bucket/myapp/v1.2.3/`, now `s3://bucket/myapp/1.2.3/`.
  Update consumers which build S3 key or Docker image tag from a version (e.g. terraform `s3_key` or `image_uri`).
  Artifacts published before keep their `v`-prefixed paths/tags, so pin old versions as `v1.2.3` and new ones as `1.2.3`
- floating tags in S3 and ECR are bare as well: was `v1`, `v1.2`, now `1`, `1.2`. Git floating tags keep `tag-format` (`v1`, `v1.2`)
- explicit `version` input: `tag-format` is now applied to the git tag (version `1.2.3` -> git tag `v1.2.3`, before it was `1.2.3`).
  A leading `v` in explicit version is ignored (`v1.2.3` -> version `1.2.3`). If you rely on git tags without prefix, set `tag-format: ${version}`
- git tags, release commit message (`Release version v1.2.3 [skip ci]`) and GH release name are unchanged (they use git tag)

## v4 -> v5

This release is to catch up with [npm changes in Dec 2025](https://github.blog/changelog/2025-12-09-npm-classic-tokens-revoked-session-based-auth-and-cli-token-management-now-available/).
The env variable `NPM_TOKEN` is now gone. Instead, you would need to use boolean input `npm-publish`.
And for actual authorization follow [Trusted publishing for npm packages](https://docs.npmjs.com/trusted-publishers)

## v3 -> v4

In version v1..3 the default preset for version generation was "angular".
And there was an ability to use other presets such as "conventionalcommits" and some less popular ones.
As time goes by, "conventionalcommits" became a de-facto standard in the industry, plus
"conventionalcommits" preset is so flexible that it allows you to mimic any other preset including "angular"!

On top of that, the use non-default present required not intuitive input `npm-extra-deps`.
So instead of making "conventionalcommits" a default,
the author decided to drop support of presets and keep only one "conventionalcommits"

- remove `npm-extra-deps` input from your workflow file
- if you use v1..3 with "conventionalcommits" preset, there will be no difference at all
- if you use v1..3 with default preset (angular), the only difference will be how "conventionalcommits" interprets take breaking changes: they use `feat!:` prefix
- if you use v1..3 with other presets, you need to migrate to "conventionalcommits" preset by configuring it via `release-plugins` input or `.releaserc.json` file
