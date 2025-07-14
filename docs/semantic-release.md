# Semantic-release usage

NPM library [semantic-release](https://github.com/semantic-release/semantic-release) is used to generate next version and release notes.
semantic-release is used in **dryRun** mode, so it doesn't commit changes, push tags, or create a GitHub release

## Presets

semantic-release itself depends on [conventional-changelog](https://github.com/conventional-changelog/conventional-changelog) library
to analyze commit messages and generate release notes. There are ~10 presets available named `conventional-changelog-{preset}`.
By default, semantic-release uses [angular](https://www.npmjs.com/package/conventional-changelog-angular) (10M weekly downloads).
Next popular alternative is [conventionalcommits](https://www.npmjs.com/package/conventional-changelog-conventionalcommits) (6M weekly downloads). To use non-default preset, you need
1) set desired preset in `@semantic-release/commit-analyzer` plugin (more details below);
2) add npm dependency via `npm_extra_deps` input in `agilecustoms/publish` action:
```yaml
- name: Release
  uses: agilecustoms/publish@main
  with:
    npm_extra_deps: conventional-changelog-conventionalcommits@9.1.0
```

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
2. [configuration file](https://semantic-release.gitbook.io/semantic-release/extending/shareable-configurations-list) (such as `.releaserc.json`) in the root of your repository
3. [shareable configurations](https://semantic-release.gitbook.io/semantic-release/extending/shareable-configurations-list)

You can change preset and effect for each prefix your own `.releaserc.json` in the root of repository.

## Examples

Example 1
```text
```

Example 2
```text
```
