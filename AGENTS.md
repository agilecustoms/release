# AGENTS.md

`agilecustoms/release` is a public composite GitHub Action: generate version (via `agilecustoms/release-gen`),
publish artifacts (S3, ECR, CodeArtifact maven, Google Artifact Registry, npmjs), push release commit and git tags,
create GH release.
`README.md` is its public page (GitHub, Marketplace): only user-facing content goes there, internals are here

## Tech summary

- Language: YAML composite action, multi-line steps are Bash scripts in `scripts/`.
  Delegates to *release-gen* (version, notes), *publish-s3* (S3 upload), *setup-maven-codeartifact* (Maven)
- Runtime: GitHub Actions runner
- Artifact: git tag `v{version}` and floating tags `v{major}`, `v{major}.{minor}`, created by CI on push to `main`.
  Branch `next` is the prerelease channel

## Context

Private agilecustoms repos use it via wrapper *gha-release*, which points to `agilecustoms/release@next`

## Layout

| Path                          | What                                                                              |
|-------------------------------|-----------------------------------------------------------------------------------|
| `action.yml`                  | inputs and steps grouped by phases: validate, generate, login, publish, git push  |
| `scripts/*.sh`                | multi-line steps; each script header lists its inputs (env) and outputs           |
| `.github/workflows/build.yml` | CI jobs: `Validate`, `Input-Validation`, `E2E-*`, `Test` (gate), `Release` (main) |
| `README.md`                   | features, inputs/outputs tables                                                   |
| `docs/`                       | artifact types, features, authorization; `docs/examples/`: copies of real repos   |

## Changes

The action is public, others depend on it: make changes following the release procedure in
[docs/contribution.md](docs/contribution.md) (branch `next`, major version and migration guide for breaking changes)

## Development

`make lint` (actionlint on workflows, shellcheck on `scripts/*.sh`), all targets are in [Makefile](Makefile).
Before finishing a change, run it and check that `action.yml` and workflows are valid YAML.
E2E tests run only in CI (they release into a local sandbox repo)

## Documentation rules

- the repo is public: in docs and examples use placeholders (`mycompany`, `my-project`, `123456789012`), not real ids
- README inputs table must match `action.yml` inputs (names,
  defaults; code-level defaults are explained in the description)
- a new input or artifact type also updates: README (inputs, "Artifact types" table), `docs/artifact-types/`,
  `docs/features/dev-release.md` (inputs respected by dev-release), `docs/features/idempotency.md`,
  `docs/troubleshooting.md` (steps)
- new artifact type checklist: `docs/contribution.md`.
  After the first real release with a new feature add a row in `docs/test-coverage.md`
- examples in `docs/examples/` mirror real repos (env-api, tt-web, envctl, java-parent,
  gha-release); when a real repo changes,
  check that the example and the doc text about it still agree.
  Examples call `agilecustoms/release@v6` with explicit inputs
  (or `mycompany/gha-release`), not agilecustoms internals
- a high-level rule (best-practices.md, authorization.md, README) and a specific doc must agree: fix both or neither
