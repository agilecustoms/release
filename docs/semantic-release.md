# Semantic-release usage

NPM library [semantic-release](https://github.com/semantic-release/semantic-release) is used to generate next version and release notes.
semantic-release is used in **dryRun** mode, so it doesn't commit changes, push tags, or create a GitHub release

## Presets

semantic-release itself depends on [conventional-changelog](https://github.com/conventional-changelog/conventional-changelog) library
to analyze commit messages and generate release notes. There are ~10 presets available named `conventional-changelog-{preset}`.
By default, semantic-release uses [angular](https://www.npmjs.com/package/conventional-changelog-angular) (10M weekly downloads).
Next popular alternative is [conventionalcommits](https://www.npmjs.com/package/conventional-changelog-conventionalcommits) (6M weekly downloads). To use non-default preset, you need
1) set desired preset in `@semantic-release/commit-analyzer` plugin (more details below)
2) add npm dependency via `npm_extra_deps` input in `agilecustoms/publish` action (see example below)

Here is the summary of the [angular](https://github.com/angular/angular/blob/main/contributing-docs/commit-message-guidelines.md) preset:

| prefix                                         | default version bump | release and changelog section                | description                                                                                                                               |
|------------------------------------------------|----------------------|----------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| `feat:` with `BREAKING CHANGE:`                | major                | Features  and  BREAKING CHANGES              | Breaking change OR just first major release. (Tag `BREAKING CHANGE:` must be in message footer)                                           |
| `feat:`                                        | minor                | Features                                     | New feature                                                                                                                               |
| `fix:`                                         | patch                | Bug Fixes                                    | Bug fix                                                                                                                                   |
| `perf:`                                        | patch                | Performance Improvements                     | Performance improvement / fix                                                                                                             |
| `build:`, `ci:`, `docs:`, `refactor:`, `test:` | no version bump      | _not reflected in GH release / CHANGELOG.md_ | See Angular [commit-message-guidelines](https://github.com/angular/angular/blob/main/contributing-docs/commit-message-guidelines.md#type) |
| _no prefix_                                    | no version bump      | _not reflected in GH release / CHANGELOG.md_ | Discouraged, but allowed                                                                                                                  |

## Plugins and dryRun mode

`agilecustoms/publish` uses semantic-release in `dryRun` mode - just to generate next version and release notes.
**Only two semantic-release plugins** are used:
[commit-analyzer](https://github.com/semantic-release/commit-analyzer) and [release-notes-generator](https://github.com/semantic-release/release-notes-generator)
so they take configuration as per `semantic-release` documentation in an extent that `dryRun` mode supports.
If you attempt to specify other plugins - they will be ignored, and you'll see a warning in logs.
For all "modify" operations (publish artifacts, git commit, GitHub release, etc.) `agilecustoms/publish` uses its own implementation

## Configuration

There are 3 ways to configure semantic-release (highest to lowest priority):
1. `agilecustoms/publish` [inputs](../README.md#inputs) in your workflow file
2. [configuration file](https://semantic-release.gitbook.io/semantic-release/usage/configuration#configuration-file) (such as `.releaserc.json`) in the root of your repository
3. [shareable configurations](https://semantic-release.gitbook.io/semantic-release/extending/shareable-configurations-list)
are **NOT SUPPORTED**. I (Alex C) checked 4 most popular configurations. Each of them provide a combination of plugins to release for particular platform.
Since `agilecustoms/publish` uses only 2 plugins (and only in `dryRun` mode) - there's no much value in support of shareable configurations

## Examples

### use patch for docs

Use `agilecustoms/publish` action with `release-plugins` input to set `patch` effect for `docs:` prefix:
```yaml
- name: Release
  uses: agilecustoms/publish@v1
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

==> new patch release, with `Bug Fixes` in release notes


### conventionalcommits

Place `.relaserc.json` in repo root (alternatively can use shareable configuration or pass plugins via `release-plugins` input in `agilecustoms/publish` action):
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

Use `npm_extra_deps` input in `agilecustoms/publish` action to add _conventionalcommits_ npm dependency:
```yaml
- name: Release
  uses: agilecustoms/publish@v1
  with:
    npm-extra-deps: conventional-changelog-conventionalcommits@9.1.0
```

Use tags in commit messages as per [conventionalcommits](https://www.conventionalcommits.org/en/v1.0.0/):
```text
feat!: support new payment provider
```

==> new major release, with `BREAKING CHANGE` in release notes

_Note, conventionalcommits allow to make major release with ! after tag, BREAKING CHANGE: is not required_
