# Configuration

`agilecustoms/release` uses npm library "semantic-release" in _dryRun_ mode — just to generate next version
and release notes.
**Only two semantic-release plugins** are used:
[commit-analyzer][commit-analyzer] and [release-notes-generator][release-notes-generator]
so they take configuration as per semantic-release documentation to an extent that _dryRun_ mode supports.
If you attempt to specify other plugins — they will be ignored, and you'll see a warning in logs.
For all "modify" operations (publish artifacts, git commit, GitHub release, etc.) `agilecustoms/release` uses its own
implementation

semantic-release takes configuration from [configuration file][configuration-file]
(such as `.releaserc.json`) in the root of repository OR via [shareable configurations][shareable-configurations].
I (Alex C) checked four most popular shareable configurations:
each of them provides a combination of plugins to release for a particular platform.
Since `agilecustoms/release` uses only two plugins (and only in dryRun mode) - there's no much value in support of
shareable configurations.
So shareable configurations are **NOT SUPPORTED**.
In addition to a semantic-release configuration file, `agilecustoms/release` takes configuration via
[inputs](../README.md#inputs).
Inputs take precedence over a configuration file

As an alternative form of configuration reuse (instead of sharable configurations) it is recommended
to create your company-specific GH action wrapper and put common configuration as default inputs in that wrapper!
See [example](./examples/gha-release/action.yml)

## Configuration options

Bottom line, these are only supported configuration options for semantic-release:

| config file section                              | GH action input    | purpose                                                                                    |
|--------------------------------------------------|--------------------|--------------------------------------------------------------------------------------------|
| `branches` ([details][configuration-branches])   | `release-branches` | mainly for [maintenance releases][maintenance-releases] and [prereleases][prereleases]     |
| `plugins`                                        | `release-plugins`  | mainly for [conventional commits][conventional-commits]                                    |
| `tagFormat` ([details][configuration-tagformat]) | `tag-format`       | git tag format (`v1.2.3`, `1.2.3`, `release-1.2.3`), version itself is always bare `1.2.3` |
| `branches > .. > channel`                        | `release-channel`  | mainly for [floating tags][floating-tags]                                                  |

[commit-analyzer]: https://github.com/semantic-release/commit-analyzer
[configuration-branches]: https://semantic-release.gitbook.io/semantic-release/usage/configuration#branches
[configuration-file]: https://semantic-release.gitbook.io/semantic-release/usage/configuration#configuration-file
[configuration-tagformat]: https://semantic-release.gitbook.io/semantic-release/usage/configuration#tagformat
[conventional-commits]: features/conventional-commits.md
[floating-tags]: features/floating-tags.md
[maintenance-releases]: features/maintenance-release.md
[prereleases]: features/prerelease.md
[release-notes-generator]: https://github.com/semantic-release/release-notes-generator
[shareable-configurations]: https://semantic-release.gitbook.io/semantic-release/extending/shareable-configurations-list
