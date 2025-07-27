# Semantic-release usage

NPM library [semantic-release](https://github.com/semantic-release/semantic-release) is used to generate next version and release notes.
semantic-release is used in **dryRun** mode, so it doesn't commit changes, push tags nor create a GitHub release

## Presets

Semantic-release itself depends on a [conventional-changelog](https://github.com/conventional-changelog/conventional-changelog) library
to analyze commit messages and generate release notes.
There are [~10 presets available](https://github.com/conventional-changelog/conventional-changelog/tree/master/packages) named `conventional-changelog-{preset}`.
By default, semantic-release uses [angular](https://www.npmjs.com/package/conventional-changelog-angular) (10M weekly downloads).
Alternative gaining popularity is [conventionalcommits](https://www.npmjs.com/package/conventional-changelog-conventionalcommits) (6M weekly downloads).
With conventionalcommits you have more flexibility on commit types and release sections (see examples below)

To use non-default preset, you need:
1) set desired preset in `@semantic-release/commit-analyzer` plugin (see example below)
2) add npm dependency via `npm_extra_deps` input in `agilecustoms/release` action (see example below)

Here is the summary of the [angular](https://github.com/angular/angular/blob/main/contributing-docs/commit-message-guidelines.md) preset:

| prefix                                         | default version bump | release and changelog section                | description                                                                                                                               |
|------------------------------------------------|----------------------|----------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| `feat:` with `BREAKING CHANGE:`                | major                | Features  and  BREAKING CHANGES              | Breaking change OR just first major release. (Tag `BREAKING CHANGE:` must be in message footer)                                           |
| `feat:`                                        | minor                | Features                                     | New feature                                                                                                                               |
| `fix:`                                         | patch                | Bug Fixes                                    | Bug fix                                                                                                                                   |
| `perf:`                                        | patch                | Performance Improvements                     | Performance improvement / fix                                                                                                             |
| `build:`, `ci:`, `docs:`, `refactor:`, `test:` | no version bump      | _not reflected in GH release / CHANGELOG.md_ | See Angular [commit-message-guidelines](https://github.com/angular/angular/blob/main/contributing-docs/commit-message-guidelines.md#type) |
| _no prefix_                                    | no version bump      | _not reflected in GH release / CHANGELOG.md_ | Discouraged, but allowed                                                                                                                  |

In normal release workflow (not [dev-release](./release-types.md)) if a PR has no any commit bumping a version,
then `agilecustoms/release` action exit with error

## Plugins and dryRun mode

`agilecustoms/release` uses semantic-release in `dryRun` mode - just to generate next version and release notes.
**Only two semantic-release plugins** are used:
[commit-analyzer](https://github.com/semantic-release/commit-analyzer) and [release-notes-generator](https://github.com/semantic-release/release-notes-generator)
so they take configuration as per `semantic-release` documentation in an extent that `dryRun` mode supports.
If you attempt to specify other plugins — they will be ignored, and you'll see a warning in logs.
For all "modify" operations (publish artifacts, git commit, GitHub release, etc.) `agilecustoms/release` uses its own implementation

## Configuration

There are 3 ways to configure semantic-release (the highest to lowest priority):
1. `agilecustoms/release` [inputs](../README.md#inputs) in your workflow file
2. [configuration file](https://semantic-release.gitbook.io/semantic-release/usage/configuration#configuration-file) (such as `.releaserc.json`) in the root of your repository
3. [shareable configurations](https://semantic-release.gitbook.io/semantic-release/extending/shareable-configurations-list)
are **NOT SUPPORTED**. I (Alex C) checked 4 most popular configurations. Each of them provides a combination of plugins to release for a particular platform.
Since `agilecustoms/release` uses only 2 plugins (and only in `dryRun` mode) - there's no much value in support of shareable configurations

Bottom line, these are only supported configuration options for semantic-release:
- [branches](https://semantic-release.gitbook.io/semantic-release/usage/configuration?utm_source=chatgpt.com#branches) —
you only need it to support maintenance releases and/or prereleases, see [release types](./release-types.md)
- `plugins`
- `tag-format` (`@agilecustoms/release` input) or `tagFormat` in `.releaserc.json`
- ⚠️ setting `repositoryUrl` in `.releaserc.json` is possible but not recommended.
I (Alex C) do not see a use case for this setting yet, so there is no corresponding input for GH action.
In the future, I might stop using `semantic-release` and switch to use `conventional-changelog` directly,
then this setting might be removed completely.

## Examples

### use patch for docs

Use `agilecustoms/release` action with `release-plugins` input to set `patch` effect for `docs:` prefix:
```yaml
- name: Release
  uses: agilecustoms/release@v1
  with:
    release-plugins: |
      [
        [
          "@semantic-release/commit-analyzer",
          {
            "releaseRules": [
              { "type": "docs", "release": "patch" }
            ]
          }
        ],
        "@semantic-release/release-notes-generator"
      ]
```

Use tags in commit messages as per [angular](https://www.npmjs.com/package/conventional-changelog-angular) specification:
```text
docs: add more examples to README
```

==> new patch version. Commit message is not reflected in release notes,
specifically no section `Documentation` nor `Bug Fixes` just title with version number


### conventionalcommits (default)

Place `.relaserc.json` in repo root
```json
{
  "plugins": [
    [
      "@semantic-release/commit-analyzer",
      {
        "preset": "conventionalcommits"
      }
    ],
    "@semantic-release/release-notes-generator"
  ]
}
```

Use `npm_extra_deps` input in `agilecustoms/release` action to add _conventionalcommits_ npm dependency:
```yaml
- name: Release
  uses: agilecustoms/release@v1
  with:
    npm-extra-deps: conventional-changelog-conventionalcommits@9.1.0
```

Use tags in commit messages as per [conventionalcommits](https://www.conventionalcommits.org/en/v1.0.0/):
```text
feat!: support new payment provider
```

==> new major version. Release notes have section `BREAKING CHANGES` with your commit message.
Note: conventionalcommits allow to make major release with `!` after tag, `BREAKING CHANGE:` tag is not required


### conventionalcommits (custom types)

Instead of `.relaserc.json` you can pass semantic-release plugins configuration via `release-plugins` input:
```yaml
- name: release
  uses: agilecustoms/release@main
  with:
    npm-extra-deps: conventional-changelog-conventionalcommits@9.1.0
    release-plugins: |
      [
        [
          "@semantic-release/commit-analyzer",
          {
            "preset": "conventionalcommits",
            "releaseRules": [
              { "type": "perf", "release": false },
              { "type": "docs", "release": "patch" },
              { "type": "misc", "release": "patch" }
            ]
          }
        ],
        [
          "@semantic-release/release-notes-generator",
          {
            "preset": "conventionalcommits",
            "presetConfig": {
              "types": [
                {
                  "type": "feat",
                  "section": "Features"
                },
                {
                  "type": "fix",
                  "section": "Bug Fixes"
                },
                {
                  "type": "docs",
                  "section": "Documentation"
                },
                {
                  "type": "misc",
                  "section": "Miscellaneous"
                }
              ]
            }
          }
        ]
      ]
```
In this example:
- `perf:` type is disabled, if I ever need it — will just include in `feat:` or `fix:`
- `docs:` will cause patch updates and show up in "Documentation" section as documentation for this project is essential
- `misc:` introduced as a way to make patch release for minor changes (such as update dependencies) and do _not_ use `fix:` for that

Use tags in commit messages as per [conventionalcommits](https://www.conventionalcommits.org/en/v1.0.0/):
```text
misc: minor improvements
fix: buf fix
docs: test documentation
```

==> new patch version. Release notes (and/or changelog) will have sections "Bug Fixes", "Documentation" and "Miscellaneous"

**Conclusion**. This option may look bulky, but it is recommended if you have many repositories that need to follow the same release pattern.
With `.relaserc.json` you'd need to copy and paste this file in all repos. Recommendation is to create your own composite GH action —
a wrapper for `agilecustoms/release` where you'll have all your semantic commit rules and then use *your GH Action* in all projects
