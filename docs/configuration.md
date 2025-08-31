# Configuration

`agilecustoms/release` uses semantic-release in _dryRun_ mode — just to generate next version and release notes.
**Only two semantic-release plugins** are used:
[commit-analyzer](https://github.com/semantic-release/commit-analyzer) and [release-notes-generator](https://github.com/semantic-release/release-notes-generator)
so they take configuration as per semantic-release documentation in an extent that _dryRun_ mode supports.
If you attempt to specify other plugins — they will be ignored, and you'll see a warning in logs.
For all "modify" operations (publish artifacts, git commit, GitHub release, etc.) `agilecustoms/release` uses its own implementation

semantic-release takes configuration from [configuration file](https://semantic-release.gitbook.io/semantic-release/usage/configuration#configuration-file)
(such as `.releaserc.json`) in the root of repository OR via [shareable configurations](https://semantic-release.gitbook.io/semantic-release/extending/shareable-configurations-list).
I (Alex C) checked four most popular shareable configurations:
each of them provides a combination of plugins to release for a particular platform.
Since `agilecustoms/release` uses only two plugins (and only in dryRun mode) - there's no much value in support of shareable configurations.
So shareable configurations are **NOT SUPPORTED**.
In addition to semantic-release configuration file, `agilecustoms/release` takes configuration via [inputs](../README.md#inputs).
Inputs take precedence over a configuration file

As an alternative form of configuration reuse (instead of sharable configurations) it is recommended
to create your company-specific GH action wrapper and put common configuration as default inputs in that wrapper!

## Configuration options

Bottom line, these are only supported configuration options for semantic-release:

| config file section                                                                                         | GH action input    | purpose                                                                                                      |
|-------------------------------------------------------------------------------------------------------------|--------------------|--------------------------------------------------------------------------------------------------------------|
| `branches` ([details](https://semantic-release.gitbook.io/semantic-release/usage/configuration#branches))   | `release-branches` | mainly for [maintenance releases](features/maintenance-release.md) and [prereleases](features/prerelease.md) |
| `plugins`                                                                                                   | `release-plugins`  | mainly for [semantic versioning](features/semantic-commits.md)                                               |
| `tagFormat` ([details](https://semantic-release.gitbook.io/semantic-release/usage/configuration#tagformat)) | `tag-format`       | tag format = version format (`v1.2.3`, `1.2.3`, `release-1.2.3`)                                             |
| `branches > .. > channel`                                                                                   | `release-channel`  | mainly for [floating tags](features/floating-tags.md)                                                        |
