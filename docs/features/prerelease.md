## Prerelease

Prerelease rules are more complex.
Here properties `prerelease` and `channel` not only contribute to floating tags, but also drive a version.
Idea is that you can do `-alfa.1..N` then `-beta.1..N` and finally `-rc.1..N` releases while staying in one branch!

| branch | version        | prerelease | channel |    | version         | git tags                | Docker tags and S3 dirs | npm tag |
|--------|----------------|------------|---------|----|-----------------|-------------------------|-------------------------|---------|
| `next` | 1.2.3          | true       |         | -> | `2.0.0-next.1`  | `2.0.0-next.1`          | _same_                  | `next`  |
| `next` | 1.2.3          | true       | false   | -> | `2.0.0-next.1`  | `2.0.0-next.1`          | _same_                  | `next`  |
| `next` | 1.2.3          | true       | 'next'  | -> | `2.0.0-next.1`  | `2.0.0-next.1`          | `2.0.0-next.2`, `next`  | `next`  |
| `next` | 1.2.3          | true       | 'beta'  | -> | `2.0.0-next.1`  | `2.0.0-next.1`, `beta`  | _same_                  | `next`  |
| `next` | 1.2.3          | 'alpha'    |         | -> | `2.0.0-alpha.1` | `2.0.0-alpha.2`         | _same_                  | `next`  |
| `next` | 1.2.3          | 'alpha'    | false   | -> | `2.0.0-alpha.1` | `2.0.0-alpha.2`         | _same_                  | `next`  |
| `next` | 1.2.3          | 'alpha'    | 'next'  | -> | `2.0.0-alpha.1` | `2.0.0-alpha.2`         | `2.0.0-alpha.2`, `next` | `next`  |
| `next` | 1.2.3          | 'alpha'    | 'beta'  | -> | `2.0.0-alpha.1` | `2.0.0-alpha.2`, `beta` | _same_                  | `next`  |

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

| branch | version       | prerelease | channel | commit | version         | git tags                | Docker tags and S3 dirs | npm tag |
|--------|---------------|------------|---------|--------|-----------------|-------------------------|-------------------------|---------|
| `next` | 2.4.0         | 'alpha'    | 'demo'  | BR CH: | `3.0.0-alpha.1` | `3.0.0-alpha.1`, `demo` | _same_                  | `demo`  |
| `next` | 3.0.0-alpha.1 | 'alpha'    | 'demo'  | fix:   | `3.0.0-alpha.2` | `3.0.0-alpha.2`, `demo` | _same_                  | `demo`  |
| `next` | 3.0.0-alpha.2 | 'beta'     | 'demo'  | feat:  | `3.0.0-beta.1`  | `3.0.0-beta.1`, `demo`  | _same_                  | `demo`  |
| `next` | 3.0.0-beta.1  | 'beta'     | 'demo'  | fix:   | `3.0.0-beta.2`  | `3.0.0-beta.2`, `demo`  | _same_                  | `demo`  |
| `next` | 3.0.0-beta.2  | 'rc'       |         | feat:  | `3.0.0-rc.1`    | `3.0.0-rc.1`            | _same_                  | `next`  |
| `next` | 3.0.0-rc.1    | 'rc'       |         | fix:   | `3.0.0-rc.2`    | `3.0.0-rc.2`            | _same_                  | `next`  |

Rules:
- change of `prerelease` drops number back to 1, so `3.0.0-alpha.2` becomes `3.0.0-beta.1`
- `channel` should **not** be changed in the middle of prerelease
- explicit `channel` gives a floating tag

Here first column "channel" is what you configure in `.releaserc.json`,
"git notes channel" is a special value used by "semantic-release" to "stitch" multiple prerelease versions together

Read about prerelease branches in [semantic-release documentation](https://semantic-release.gitbook.io/semantic-release/usage/workflow-configuration#pre-release-branches)
