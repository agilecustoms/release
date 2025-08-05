# Version generation

There are three ways to generate a new version:

1. (recommended) use [semantic commits](./semantic-release.md) — next version determined based on commit message prefixes
   such as `fix:`, `feat:`, `docs:`, `perf:`
2. [minor version bump](#minor-version-bump) — allows to bump a minor version w/o semantic commits
3. [Explicit version](#explicit-version) allows providing a new version as explicit input 

[semantic commits](./semantic-release.md) is recommended way, it allows you to use all features of this action (see table below).
Big enterprise often does not need the full power of semantic commits but rather chooses simplicity.
Finally, some projects seeking more flexibility may want to use explicit versioning.

| name                 | semantic commits | minor version bump | explicit version |
|----------------------|------------------|--------------------|------------------|
| release notes        | ✅                | ❌️                 | ❌️               |
| changelog            | ✅                | ❌️                 | ❌️               |
| floating tags        | ✅                | ✅                  | ✅                |
| release channel      | ✅                | ⚠️                 | ⚠️               |
| prerelease           | ✅                | ❌️                 | ✅                |
| maintenance releases | ✅                | ⚠️                 | ✅                |

⚠️ Notes:
- "semantic commits" takes 'release channel' from `.releaserc.json` file.
"default minor" and "explicit version" must use `release-channel` input parameter instead
- Maintenance releases can be `N.x.x` (can bump minor and patch versions) and `N.N.x` (can bump only a patch version).
  `minor-version-bump` can only be used with `N.x.x`

## Minor version bump

`minor-version-bump` has 3 modes:
1. (no-value) — default, meaning use semantic commits
2. `default` — use semantic commits, but if no commits found since last release, then a minor version will be bumped
3. `always` — always bump a minor version, ignoring semantic commits

## Explicit version

Use the `version` input parameter to specify an exact version instead of auto-generating one.
When provided, only this single version/tag will be created (no `latest`, `major`, or `minor` tags).
Typically, you use normal release flow (for trunk-based development) or `dev-release: true` to test some feature before merging it.

Use explicit **version** as last resort:
1. to fix an existing version in-place
2. instead of dev-release when it is not supported
