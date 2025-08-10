# Configuration (WIP)

## Plugins and dryRun mode

`agilecustoms/release` uses semantic-release in `dryRun` mode - just to generate next version and release notes.
**Only two semantic-release plugins** are used:
[commit-analyzer](https://github.com/semantic-release/commit-analyzer) and [release-notes-generator](https://github.com/semantic-release/release-notes-generator)
so they take configuration as per `semantic-release` documentation in an extent that `dryRun` mode supports.
If you attempt to specify other plugins — they will be ignored, and you'll see a warning in logs.
For all "modify" operations (publish artifacts, git commit, GitHub release, etc.) `agilecustoms/release` uses its own implementation

## Configuration

There are 3 ways to configure semantic-release (the highest to lowest priority):
1. `agilecustoms/release` [inputs](./../../README.md#inputs) in your workflow file
2. [configuration file](https://semantic-release.gitbook.io/semantic-release/usage/configuration#configuration-file) (such as `.releaserc.json`) in the root of your repository
3. [shareable configurations](https://semantic-release.gitbook.io/semantic-release/extending/shareable-configurations-list)
   are **NOT SUPPORTED**. I (Alex C) checked 4 most popular configurations. Each of them provides a combination of plugins to release for a particular platform.
   Since `agilecustoms/release` uses only 2 plugins (and only in `dryRun` mode) - there's no much value in support of shareable configurations

Bottom line, these are only supported configuration options for semantic-release:
- [branches](https://semantic-release.gitbook.io/semantic-release/usage/configuration?utm_source=chatgpt.com#branches) —
  you only need it to support [maintenance releases](./maintenance-release.md) and [prereleases](./prerelease.md)
- `plugins`
- `tag-format` (`@agilecustoms/release` input) or `tagFormat` in `.releaserc.json`
- ⚠️ setting `repositoryUrl` in `.releaserc.json` is possible but not recommended.
  I (Alex C) do not see a use case for this setting yet, so there is no corresponding input for GH action.
  In the future, I might stop using `semantic-release` and switch to use `conventional-changelog` directly,
  then this setting might be removed completely.
