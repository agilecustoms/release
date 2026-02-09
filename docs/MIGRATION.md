# Migration Guide

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
