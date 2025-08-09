# Semantic commits

`agilecustoms/release` action supports [3 modes of version generation](./version-generation.md).
This chapter describes the default mode — "semantic commits"

"semantic commits" mode is powered by NPM library [semantic-release](https://github.com/semantic-release).
It takes latest [SemVer](https://semver.org) tag and analyzes commit messages to determine a next version following these rules:
- commits with `fix:` prefix ⇒ increment a patch version
- commits with `feat:` prefix ⇒ increment a minor version
- commits with `BREAKING CHANGE:` ⇒ increment a major version

If a PR has no commit bumping a version, the `agilecustoms/release` action exit with error

Tech note. `agilecustoms/release` action uses semantic-release in **dryRun** mode:
it generates next version and release notes.
It doesn't commit changes, push tags nor create a GitHub release

## Presets

Semantic-release itself depends on a [conventional-changelog](https://github.com/conventional-changelog/conventional-changelog) library
to analyze commit messages and generate release notes.
There are [~10 presets available](https://github.com/conventional-changelog/conventional-changelog/tree/master/packages) named `conventional-changelog-{preset}`.
By default, semantic-release uses [angular](https://www.npmjs.com/package/conventional-changelog-angular) (10M weekly downloads).
Alternative gaining popularity is [conventionalcommits](https://www.npmjs.com/package/conventional-changelog-conventionalcommits) (6M weekly downloads).
With conventionalcommits you have more flexibility on commit types and release sections (see examples below)

**Configuration** can be provided via `release-plugins` input via `plugins` section in file `.releaserc.json`
To use non-default preset, you need:
1) set desired preset in `@semantic-release/commit-analyzer` plugin (see example below)
2) add npm dependency via `npm-extra-deps` input in `agilecustoms/release` action (see example below)

Here is the summary of the [angular](https://github.com/angular/angular/blob/main/contributing-docs/commit-message-guidelines.md) preset (so you can understand are you fine with default or you need more):

| prefix                                         | version bump      | release and changelog sections               | description                                                                                                                               |
|------------------------------------------------|-------------------|----------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| `feat:` with `BREAKING CHANGE:`                | major             | Features  and  BREAKING CHANGES              | Breaking change OR just first major release. (Tag `BREAKING CHANGE:` must be in message footer)                                           |
| `feat:`                                        | minor             | Features                                     | New feature                                                                                                                               |
| `fix:`                                         | patch             | Bug Fixes                                    | Bug fix                                                                                                                                   |
| `perf:`                                        | patch             | Performance Improvements                     | Performance improvement / fix                                                                                                             |
| `build:`, `ci:`, `docs:`, `refactor:`, `test:` | _no version bump_ | _not reflected in GH release / CHANGELOG.md_ | See Angular [commit-message-guidelines](https://github.com/angular/angular/blob/main/contributing-docs/commit-message-guidelines.md#type) |
| _no prefix_                                    | _no version bump_ | _not reflected in GH release / CHANGELOG.md_ | Discouraged, but allowed                                                                                                                  |

## Examples

### use patch for docs

Assume you want to bump a patch version for `docs:` prefix (by default patch bumped only for `fix:` and `perf:`).
In this example we'll provide configuration via `release-plugins` input:

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

Make a commit with messages as per [angular](https://www.npmjs.com/package/conventional-changelog-angular) specification:
```text
docs: add more examples to README
```

==> new patch version. Commit message is not reflected in release notes,
specifically no section `Documentation` nor `Bug Fixes` just title with version number


### conventionalcommits

Assume you want to use non-default preset `conventionalcommits` (instead of `angular`).
In this example we'll put configuration in `.relaserc.json` file in repo root:

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

Use `npm-extra-deps` input in `agilecustoms/release` action to add _conventionalcommits_ npm dependency:
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

Let's consider a comprehensive example of using `conventionalcommits` preset with custom commit types and sections in release notes.
Configuration will be provided via `release-plugins` input in `agilecustoms/release` action:

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

**Conclusion**. Providing semantic commits behavior via GH action input look bulky,
but it is recommended if you have many repositories that need to follow the same release pattern.
With `.relaserc.json` you'd need to copy and paste this file in all repos. Recommendation is to create your own composite GH action —
a wrapper for `agilecustoms/release` where you'll have all your semantic commit rules and then use *your GH Action* in all projects
