# Prerelease

_This document assumes you use [version generation](./version-generation.md) mode "semantic commits" or "version bump".
"explicit version" does not provide any help with respect to prerelease versions, all you get is just [floating tags](./floating-tags.md)_

Prereleases allow to evolve a version `-alfa.1..N` → `-beta.1..N` → `-rc.1..N` while staying in the same branch!

**Branch**. First, create a branch. `next` is a recommended branch name because it is not tied to any specific suffix
and allows to change it as your software gets more stable

Configure GitHub workflow (e.g. `.github/workflows/release.yaml`) to trigger on this branch:
```yaml
on:
  push:
    branches:
      - main
      - next
```

**Configuration**. Configure the branch as prerelease: set branch property `prerelease` in `.releaserc.json` file (recommended) or via `release-branches` input
This property can be `true` or a string like `alpha`, `beta`, `rc` etc.
- `prerelease: true` means "use branch name as version suffix", ex: `next` branch → `2.0.0-next.1`
- `prerelease: <suffix>` means "use <suffix> as version suffix", ex: `prerelease: "alpha"` → `2.0.0-alpha.1`

Additionally, you can use property `channel` for [floating tags](./floating-tags.md)

**First commit** is very important — it defines a version you intend to release at the end.
Most of the time prerelease is used to start work on a new major version,
so the first commit in `next` branch should have `BREAKING CHANGE: ..` in message footer (for angular)
or start from `feat!: ..` (for conventionalcommits)

Assume you made branch `next` from `main` at version `1.2.3`
- "semantic commits" mode with commit `BREAKING CHANGE:` will create version `2.0.0-next.1`
- "semantic commits" mode with commit `feat: ..` will create version `1.3.0-next.1`
- "semantic commits" mode with commit `fix: ..` will create version `1.2.4-next.1`
- "version bump" mode with `default-patch` will create version `1.2.4-next.0`
- "version bump" mode with `default-minor` will create version `1.3.0-next.0`
Note: if you use "version bump" mode and want a next major version, in the first commit you must follow "semantic commits" rules

Next table shows behavior with first major commit and different combinations of `prerelease` and `channel`:

| branch | version | prerelease | channel |   | version         | git tags                | Docker tags and S3 dirs | npm tag |
|--------|---------|------------|---------|---|-----------------|-------------------------|-------------------------|---------|
| `next` | 1.2.3   | _true_     |         | ⇒ | `2.0.0-next.1`  | `2.0.0-next.1`          | _same_                  | `next`  |
| `next` | 1.2.3   | _true_     | _false_ | ⇒ | `2.0.0-next.1`  | `2.0.0-next.1`          | _same_                  | `next`  |
| `next` | 1.2.3   | _true_     | next    | ⇒ | `2.0.0-next.1`  | `2.0.0-next.1`          | `2.0.0-next.2`, `next`  | `next`  |
| `next` | 1.2.3   | _true_     | beta    | ⇒ | `2.0.0-next.1`  | `2.0.0-next.1`, `beta`  | _same_                  | `next`  |
| `next` | 1.2.3   | alpha      |         | ⇒ | `2.0.0-alpha.1` | `2.0.0-alpha.2`         | _same_                  | `next`  |
| `next` | 1.2.3   | alpha      | _false_ | ⇒ | `2.0.0-alpha.1` | `2.0.0-alpha.2`         | _same_                  | `next`  |
| `next` | 1.2.3   | alpha      | next    | ⇒ | `2.0.0-alpha.1` | `2.0.0-alpha.2`         | `2.0.0-alpha.2`, `next` | `next`  |
| `next` | 1.2.3   | alpha      | beta    | ⇒ | `2.0.0-alpha.1` | `2.0.0-alpha.2`, `beta` | _same_                  | `next`  |

**Subsequent commits**. No matter what semantic commit you make (`fix:`, `feat:` etc.) or "version bump" `default-patch`/`default-minor` you use,
the version will always be incremented `+1` in the prerelease sequence: `2.0.0-alpha.1` → `2.0.0-alpha.2`.
In case of "semantic commits", the commit messages still matter: they're used to generate GitHub releases.
Also, once you finally merge prerelease branch → main, then all semantic commits will be reflected in a `CHANGELOG.md` file

**Merge to main**. Use merge commit. Do not use rebase because last commit in `next` has `[skip ci]` tag,
so release workflow will not be triggered on `main`.
Do not use squash because you will lose all semantic commits in the prerelease branch!

## Big example

Given branch `main` with current version 2.4.0. Create branch `next` with following `.releaserc.json`:

```json
{
  "branches": [
    "main",
    {
      "name": "next",
      "prerelease": "alpha",
      "channel": "demo"
    }
  ]
}
```

In the table below each row represents a commit in the `next` branch:

| branch | version       | prerelease | channel | commit |   | version                 | git tags                | Docker tags and S3 dirs | npm tag |
|--------|---------------|------------|---------|--------|---|-------------------------|-------------------------|-------------------------|---------|
| `next` | 2.4.0         | alpha      | demo    | BR CH: | ⇒ | `3.0.0-alpha.1`         | `3.0.0-alpha.1`, `demo` | _same_                  | `demo`  |
| `next` | 3.0.0-alpha.1 | alpha      | demo    | fix:   | ⇒ | `3.0.0-alpha.2`         | `3.0.0-alpha.2`, `demo` | _same_                  | `demo`  |
| `next` | 3.0.0-alpha.2 | beta       | demo    | feat:  | ⇒ | `3.0.0-beta.1`          | `3.0.0-beta.1`, `demo`  | _same_                  | `demo`  |
| `next` | 3.0.0-beta.1  | beta       | demo    | fix:   | ⇒ | `3.0.0-beta.2`          | `3.0.0-beta.2`, `demo`  | _same_                  | `demo`  |
| `next` | 3.0.0-beta.2  | rc         |         | feat:  | ⇒ | `3.0.0-rc.1`            | `3.0.0-rc.1`            | _same_                  | `next`  |
| `next` | 3.0.0-rc.1    | rc         |         | fix:   | ⇒ | `3.0.0-rc.2`            | `3.0.0-rc.2`            | _same_                  | `next`  |

Rules:
- change of `prerelease` drops number back to 1, so `3.0.0-alpha.2` becomes `3.0.0-beta.1`
- `channel` should **not** be changed in the middle of prerelease sequence
- explicit `channel` gives a floating tag

Read more about prerelease branches in [semantic-release documentation](https://semantic-release.gitbook.io/semantic-release/usage/workflow-configuration#pre-release-branches)
