# Semantic-release usage

NPM library [semantic-release](https://github.com/semantic-release) is used to generate next version and release notes.
- Default preset is [conventional-changelog-angular](https://www.npmjs.com/package/conventional-changelog-angular) (10M weekly downloads)
- alternative: [conventional-changelog-conventionalcommits](https://www.npmjs.com/package/conventional-changelog-conventionalcommits) (6M weekly downloads)
- more alternatives: TBD

You can change preset and effect for each prefix your own `.releaserc.json` in the root of repository.
Short summary of the [angular](https://github.com/angular/angular/blob/main/contributing-docs/commit-message-guidelines.md) preset:

| prefix                                         | default version bump | release and changelog section                | description                                                                                                                               |
|------------------------------------------------|----------------------|----------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| `feat:` with `BREAKING CHANGE:`                | major                | Features  and  BREAKING CHANGES              | Breaking change OR just first major release. (Tag `BREAKING CHANGE:` must be in message footer)                                           |
| `feat:`                                        | minor                | Features                                     | New feature                                                                                                                               |
| `fix:`                                         | patch                | Bug Fixes                                    | Bug fix                                                                                                                                   |
| `perf:`                                        | patch                | Performance Improvements                     | Performance improvement/fix                                                                                                               |
| `build:`, `ci:`, `docs:`, `refactor:`, `test:` | no version bump      | _not reflected in GH release / CHANGELOG.md_ | See Angular [commit-message-guidelines](https://github.com/angular/angular/blob/main/contributing-docs/commit-message-guidelines.md#type) |
| _no prefix_                                    | no version bump      | _not reflected in GH release / CHANGELOG.md_ | Discouraged, but allowed                                                                                                                  |

Example 1
```text
```

Example 2
```text
```

**semantic-release** is used in `dryRun` mode, so it doesn't commit changes, push tags, or create a GitHub release.
Semantic-release has a rich family of plugins and shared configuration. `agilecustoms/publish` action uses only two main plugins:
[commit-analyzer](https://github.com/semantic-release/commit-analyzer) and [release-notes-generator](https://github.com/semantic-release/release-notes-generator)
so they take configuration as per `semantic-release` documentation in an extent that `dryRun` mode supports.
Plugin [changelog](https://github.com/semantic-release/changelog) is not used,
instead `agilecustoms/publish` implements its own logic to update `CHANGELOG.md` file,
but you can use same options as for `changelog` plugin: `changelog-file` and `changelog-title`
