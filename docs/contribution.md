# Contribution guideline

For any bugs, feel free to create an issue or raise a pull request with fix

## Release procedure

The action is public: a change must not break the workflow of those who use it.
Every push to `main` is released, the version is derived from the commit prefix (conventional commits):
`fix:`, `misc:`, `docs:`, `build:` -> patch, `feat:` -> minor, `feat!:` or `BREAKING CHANGE:` footer -> major

Changes are developed in branch `next` and tested in real projects before they are released:

1. commit and push to `next`: CI runs all tests (incl. E2E in a sandbox repo), but doesn't release
2. use `agilecustoms/release@next` in your own projects and run real releases with it
   (agilecustoms private repos always do: their wrapper action points to `@next`)
3. a breaking change: commit with `feat!:` and a `BREAKING CHANGE:` footer,
   add a section to [MIGRATION.md](MIGRATION.md): what changed and what users need to do
4. after testing: create a PR `next` -> `main` and merge it with a merge commit
   (fast-forward or rebase brings `Release version ... [skip ci]` as the head commit and no workflow runs on `main`).
   Wait for the `Release` job on `main`
5. recreate `next` from `main` (GitHub deletes it on merge) and push it

## semantic-release notes

If you need some specific `semantic-release` plugin supported, please start a discussion first,
do not create an issue/PR

## Other cloud providers

Please do not add other cloud providers directly in this action.
As of June 2025 `agilecustoms/release` uses 6 other GH actions
— all of them resolved at runtime even though some of them might not be used, such as you do not use CodeArtifact,
but still load related actions.
Adding of another cloud provider support will increase the number of unused actions even more!
Instead, feel free to fork with a prefix say 'gc-' for Google Cloud

## New artifact type checklist:

- make sure it is idempotent (can be re-run w/o side effects)
- floating tags support: 'major', 'major.minor', 'major.minor.patch'
- release channel support: 'latest' (default for main)
- add dev-release mode support. if dev-release mode is not possible (like with npmjs) — document it
- verify inputs to detect configuration issues; error messages should provide suggestions on how to fix these issues
