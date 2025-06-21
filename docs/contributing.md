# Contribution guideline
Please do not add other cloud providers directly in this action.
As of June 2024 `agilecustoms/release` uses 4 other GH actions - all of them resolved runtime even though some of them might not be used,
such as you do not use CodeArtifact, but still load related actions.
Adding of another cloud provider support will make amount of unused actions loaded even bigger.
Instead feel free to fork with prefix say 'gc-' for Google Cloud

## New artifact type:
- make sure it is idempotent (can be re-run w/o side effects)
- if artifact is tag-based, make sure you publish several tags: 'latest', 'major', 'major.minor', 'major.minor.patch'
- add support of dev-release mode. if dev-release mode is not possible (like with npmjs) - just document it
