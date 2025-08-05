# Version generation

1. Semantic-release
2. Automatic minor version bump
3. Explicit version

## Automatic minor version bump

### explicit version

Use the `version` input parameter to specify an exact version instead of auto-generating one.
When provided, only this single version/tag will be created (no `latest`, `major`, or `minor` tags).
Typically, you use normal release flow (for trunk-based development) or `dev-release: true` to test some feature before merging it.

Use explicit **version** as last resort:
1. to fix an existing version in-place
2. instead of dev-release when it is not supported
