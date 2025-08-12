# Version generation

There are three ways to generate the next version:

1. [semantic commits](./semantic-commits.md) (recommended) — next version determined based on commit message prefixes
   such as `fix:`, `feat:`, `docs:`, `perf:`
2. [version bump](#version-bump) — allows to bump a version w/o semantic commits
3. [explicit version](#explicit-version) — provide a new version as explicit input 

[Semantic commits](./semantic-commits.md) is recommended way, it allows you to use all features of this action (see table below).
Big enterprise often does not need the full power of semantic commits but rather chooses simplicity.
Projects seeking more flexibility may want to use explicit versioning

| feature              | semantic commits | version bump | explicit version |
|----------------------|------------------|--------------|------------------|
| release notes        | ✅                | ❌️           | ❌️               |
| changelog            | ✅                | ❌️           | ❌️               |
| floating tags        | ✅                | ✅            | ✅                |
| release channel      | ✅                | ✅            | ⚠️               |
| prerelease           | ✅                | ⚠️           | ⚠️               |
| maintenance releases | ✅                | ✅            | ⚠️               |

See ⚠️ notes in the respective sections below

## Version bump

Semantic versioning makes most of sense when you do not know your customers,
so you can say "this release is not risky, it is just a bugfix" or "this release comes with a new feature but doesn't break anything".
In enterprise the software is being developed, deployed and tested by the same team, so teams often do not use semantic commits.
All that matters — the version is bumped, artifacts are published. For such teams there is an option `version-bump`,
it allows to bump a minor/patch version even if there are no semantic commits

`version-bump` can take the following values:
- (no-value) — default, meaning use semantic commits
- `default-patch` — if no semantic commits, default to patch bump
- `default-minor` — if no semantic commits, default to minor bump
- (planned) `patch` — bump a patch version, ignore semantic commits
- (planned) `minor` — bump a minor version, ignore semantic commits

⚠️ See [prerelease](./prerelease.md) for details on how to make first commit in prerelease branch

After first commit values `default-patch` and `default-minor` behave identical — just increment number in suffix `beta.1` -> `beta.2` 

## Explicit version

Alternatively to "semantic commits" and "version bump", you can provide an explicit version to be used for the release

This can be helpful in the following cases:
- you have your own versioning scheme like `yyyy-mm-dd-HH:mm:ss`
- you do not want to release every time a PR is merged in the main branch, but rather want to release on demand
- quick alternative instead of fully fledged [prereleases](./prerelease.md) or [maintenance release](./maintenance-release.md)
- (rare, typically not recommended) you want to re-release an existing version

⚠️ "explicit version" takes "release channel" from `release-channel` input parameter
("semantic commits" and "version bump" take it from `.releaserc.json` file)

⚠️ it is possible to do prerelease and maintenance releases in "explicit version",
but `agilecustoms/release` action does not provide any assistance/guardrails 
