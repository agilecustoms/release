# Contribution guideline

For any bugs, feel free to create an issue or raise a pull request wit fix

## semantic-release notes

If you need some specific `semantic-release` plugin supported, please start a discussion first, do not create an issue/PR

## Other cloud providers

Please do not add other cloud providers directly in this action.
As of June 2025 `agilecustoms/release` uses 6 other GH actions — all of them resolved runtime even though some of them might not be used,
such as you do not use CodeArtifact, but still load related actions.
Adding of another cloud provider support will make the number of unused actions loaded even bigger!
Instead, feel free to fork with a prefix say 'gc-' for Google Cloud

## New artifact type:

Checklist for a new artifact type:
- make sure it is idempotent (can be re-run w/o side effects)
- if the artifact is tag-based, make sure you publish several tags: 'latest', 'major', 'major.minor', 'major.minor.patch'
- add dev-release mode support. if dev-release mode is not possible (like with npmjs) — just document it
- document if there are any nuances in 'prerelease' mode
