# Floating tags and release channel

**Floating tags** are tags that move! When you release `1.2.4` then tags `1` and `1.2` move to point to `1.2.4`.
This feature primarily supported by Git and Docker, they both use tags. It is also supported by AWS S3.
AWS S3 mimics file system structure: path/object ~ dir/file. Given version stored in dir `1.2`, you can override its content
— sort of "move" the tag

**Release channel** is a term from NPM, where you can publish a package to a specific channel, like `latest` or `beta`.
Release channel reflects the purpose/audience of the release: `latest` for stable releases, `alpha`/`beta`/`rc` for prereleases.
Git, ECR and S3 adopt "release channel" by virtue of using tags and directories

Consider git branches (from old to new):
- `1.1.x` — maintenance branch for the old version, only patches are applied, currently at v _1.1.10_
- `1.x.x` — maintenance branch for the previous version, currently at v _1.5.5_
- `main` — main release branch, currently at v _2.2.2_

| branch  | version | channel   |   | version        | git tags                       | Docker tags and S3 dirs      | npm tag |
|---------|---------|-----------|---|----------------|--------------------------------|------------------------------|---------|
| `1.1.x` | 1.1.10  |           | ⇒ | _1.1.11_       | `1.1.11`, `1.1`                | _same_                       | 1.1.x   |
| `1.1.x` | 1.1.10  | false     | ⇒ | _1.1.11_       | `1.1.11`, `1.1`                | _same_                       | 1.1.x   |
| `1.1.x` | 1.1.10  | '1.1.x'   | ⇒ | _1.1.11_       | `1.1.11`, `1.1`                | `1.1.11`, `1.1`, `1.1.x`     | 1.2.x   |
| `1.1.x` | 1.1.10  | 'legacy'  | ⇒ | _1.1.11_       | `1.1.11`, `1.1`, `legacy`      | _same_                       | legacy  |
| `1.x.x` | 1.5.5   |           | ⇒ | _1.6.0_        | `1.6.0`, `1.6`, `1`            | _same_                       | 1.x.x   |
| `1.x.x` | 1.5.5   | '1.x.x'   | ⇒ | _1.6.0_        | `1.6.0`, `1.6`, `1`            | `1.6.0`, `1.6`, `1`, `1.x.x` | 1.x.x   |
| `1.x.x` | 1.5.5   | 'support' | ⇒ | _1.6.0_        | `1.6.0`, `1.6`, `1`, `support` | _same_                       | support |
| `main`  | 2.2.2   |           | ⇒ | _2.3.0_        | `2.3.0`, `2.3`, `2`, `latest`  | _same_                       | latest  |
| `main`  | 2.2.2   | false     | ⇒ | _2.3.0_        | `2.3.0`, `2.3`, `2`            | _same_                       | main    |
| `main`  | 2.2.2   | 'main'    | ⇒ | _2.3.0_        | `2.3.0`, `2.3`, `2`            | `2.3.0`, `2.3`, `2`, `main`  | main    |
| `main`  | 2.2.2   | 'release' | ⇒ | _2.3.0_        | `2.3.0`, `2.3`, `2`, `release` | _same_                       | release |

Release channel for prerelease has special semantics, see [prerelease](./prerelease.md) for details

Rules:
- [dev-release](./dev-release.md) has no floating tags
- `floating-tags: false` disable floating tags: old ones do not move, new ones are not created
- prerelease can only have a release channel tag (no numerical floating numbers)
- maintenance and prerelease by default do not have a release channel tag
- maintenance release from branch like `1.1.x` only gives floating tag of `1.1`, no `1`
- normal release by default has tag `latest`, you can set release channel `false` to disable it
- if a release channel equals to the branch name, then the corresponding git tag is not created, but docker tag and S3 dir are created

## Release channel configuration

For all configuration options, see [configuration](./configuration.md)

GH Action `agilecustoms/release` uses npm library [semantic-release](https://www.npmjs.com/package/semantic-release) under the hood.
It takes [configuration](https://semantic-release.gitbook.io/semantic-release/usage/configuration#configuration-file) from file `.releaserc.json` in the root of repository.
You can configure a release channel in `.releaserc.json` file or via GH action input `release-channel`. Input has precedence over a config file.
`.releaserc.json` is recommended because it allows to have different configurations per repo and per branch.
`release-channel` input is needed when you use "version bump" or "explicit version", see [version generation](./version-generation.md)

Example of `.releaserc.json` for a table above:
```json
{
  "branches": [
    {
      "name": "1.1.x",
      "channel": "legacy"
    },
    {
      "name": "1.x.x",
      "channel": "support"
    },
    {
      "name": "main",
      "channel": "release"
    }
  ]
}
```
