# Troubleshooting

All errors are grouped by steps of release action:
1. Validate
2. Release generation
3. Login in AWS
4. Prepare
5. Publish artifacts
6. Git push
7. GitHub release
8. Print summary

## 2. Release generation

**New version is not generating**

possible reasons:
- you forgot to add any semantic commit tag (e.g. `feat:`, `fix:`, etc.)
- perhaps you added semantic commit(s), but none of them bump a version, like `docs: update README.md`.
You either need to change it OR change configuration to make patch bump on 'docs:',
see [conventionalcommits (custom types)](./features/semantic-commits.md#conventionalcommits-custom-types)
- you did 'sqush' commits and forgot to add a semantic commit tag to the squashed commit message

**Use non default preset, but miss npm dependency**

If you use non-default preset, like `conventionalcommits`, you need to add it as npm dependency,
see [conventionalcommits (default)](./features/semantic-commits.md#conventionalcommits-default)

## 6. Git push

Error: GH013: Repository rule violations found for refs/heads/_branch-name_<br>
Reason: You're trying to release from a protected branch, while using default token with `permissions: write`
OR you're using a PAT, but it has not enough permissions to push to the branch<br>
Solution: Use fine-grained PAT with `Contents "Read and write"` or classic PAT with `repo` scope.
PAT must be issued by a person who has permission to bypass the branch protection rules.