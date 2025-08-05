# Troubleshooting

**Missing semantic commit that bumps the version**

possible reasons:
- you forgot to add any semantic commit tag (e.g. `feat`, `fix`, etc.)
- perhaps you added semantic commit(s), but none of them bump a version, like `docs: update README.md`.
You either need to change it OR change configuration to make patch bump on 'docs:',
see [conventionalcommits (custom types)](./features/semantic-release.md#conventionalcommits-custom-types)
- you did 'sqush' commits and forgot to add a semantic commit tag to the squashed commit message

**Use non default preset, but miss npm dependency**

If you use non-default preset, like `conventionalcommits`, you need to add it as npm dependency,
see [conventionalcommits (default)](./features/semantic-release.md#conventionalcommits-default)
