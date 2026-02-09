# Conventional commits

`agilecustoms/release` action supports [3 modes of version generation](./version-generation.md).
This chapter describes the default mode — "conventional commits"

"conventional commits" mode follows [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0) specification.
It takes the latest [SemVer](https://semver.org) tag and analyzes commit messages to determine the next version following these rules:
- commit with `feat!:` prefix ⇒ increment a major version
- commit with `feat:` prefix ⇒ increment a minor version
- commit with `fix:` or `perf:` prefix ⇒ increment a patch version

If a PR has no commit bumping a version, the `agilecustoms/release` action exit with error

Besides version bumping, conventional commits are reflected in GH Release and CHANGELOG.md

| prefix      | version bump      | GH Release and CHANGELOG.md sections         | Description                                 |
|-------------|-------------------|----------------------------------------------|---------------------------------------------|
| `feat!:`    | major             | Features  and  BREAKING CHANGES              | Breaking change OR just first major release |
| `feat:`     | minor             | Features                                     | New feature                                 |
| `fix:`      | patch             | Bug Fixes                                    | Bug fix                                     |
| `perf:`     | patch             | Performance Improvements                     | Performance improvement / fix               |
| _no prefix_ | _no version bump_ | _not reflected in GH release / CHANGELOG.md_ | Discouraged, but allowed                    |

This is a default (out of the box) behavior. You can configure:
- additional prefixes (such as `docs:`, `chore:`, `build:` etc.)
- mute default ones (for example, do not use `perf:` prefix)
- map prefixes to different version bumps (for example, make `docs:` cause patch version bump)
- customize sections in GH Release and CHANGELOG.md, for example group `fix:` and `perf:` under "Bug Fixes" section

**Configuration** can be provided via GH action `release-plugins` input OR in file `.releaserc.json` section `plugins`

## Custom configuration example

Let's consider a comprehensive example with custom commit types and sections in Release notes.
Configuration will be provided via `release-plugins` input in `agilecustoms/release` action:

```yaml
- name: release
  uses: agilecustoms/release@v5
  with:
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

Use prefixes in commit messages as per [conventionalcommits](https://www.conventionalcommits.org/en/v1.0.0/):
```text
misc: minor improvements
fix: buf fix
docs: test documentation
```

==> new patch version. Release notes (and/or changelog) will have sections "Bug Fixes", "Documentation" and "Miscellaneous"

**Conclusion**. Providing conventional commits behavior via GH action input looks bulky,
but it is recommended if you have many repositories that need to follow the same release pattern.
With `.relaserc.json` you'd need to copy and paste this file in all repos.
Recommendation is to create your own composite GH action — a wrapper for `agilecustoms/release`
where you'll have all your conventional commits' rules and then use *your GH Action* in all projects,
see [example](../examples/gha-release/action.yml)
