# Prerelease

Prereleases allow to evolve a version `-alfa.1..N` -> `-beta.1..N` -> `-rc.1..N` while staying in one branch!

No matter what semantic commit you make (`fix:`, `feat:` etc.),
the version will always be incremented `+1` in the prerelease sequence: `2.0.0-alpha.1` -> `2.0.0-alpha.2`.
But commit messages still matter! They go to GH release as for normal releases.
Once you finally merge prerelease branch --> main, then all semantic commits will be reflected in a `CHANGELOG.md` file

Prerelease require to set `prerelease` property on desired branch (`.releaserc.json` file or `release-branches` input).
This property can be `true` or a string like `alpha`, `beta`, `rc` etc.
- `prerelease: true` means "use branch name as prerelease suffix", ex: `next` branch -> `2.0.0-next.1`
- `prerelease: <suffix>` means "use <suffix> as prerelease suffix", ex: `prerelease: "alpha"` -> `2.0.0-alpha.1`

Additionally, you can use property `channel` for [floating tags](./floating-tags.md)

Given `next` branch created out of `main` branch with current version 1.2.3, these are possible combinations:

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

Big example. Given branch `main` with current version 2.4.0. Create branch `next` with following `.releaserc.json`:

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
