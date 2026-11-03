# AGENTS.md

Shared agilecustoms rules (git, code style) are in `../tools/agents/AGENTS.md`.
This file is `release` specific.

`agilecustoms/release` is a public composite GitHub Action: generate version (via `agilecustoms/release-gen`),
publish artifacts (S3, ECR, CodeArtifact maven, Google Artifact Registry, npmjs), push release commit and git tags, create GH release.
Private repos use it via wrapper `agilecustoms/gha-release`, which points to `agilecustoms/release@next`

## Layout

| Path                          | What                                                                                      |
|-------------------------------|-------------------------------------------------------------------------------------------|
| `action.yml`                  | the action: inputs and steps grouped by phases (validate, generate, login, publish, git push) |
| `scripts/*.sh`                | multi-line steps; each script header lists its inputs (env) and outputs                   |
| `.github/workflows/build.yml` | CI: `Validate` (shellcheck), `Input-Validation`, `E2E-*`, `Test` (gate), `Release` (main only) |
| `README.md`                   | features, inputs/outputs tables                                                           |
| `docs/`                       | artifact types, features, authorization; `docs/examples/`: trimmed copies of real repos |

## Branches and release

- develop in `next` (safe: `gha-release` uses `@next`, so private repos test new features before they are released)
- release = merge `next` -> `main` with a **merge commit**. Fast-forward/rebase brings `Release version ... [skip ci]`
  as the head commit and no workflow runs on `main`
- no Makefile here. Before finishing a change: shellcheck (`docker run --rm -v "$PWD:/mnt" -w /mnt koalaman/shellcheck:stable scripts/*.sh`)
  and check that `action.yml` and workflows are valid YAML. E2E tests run only in CI (they release into a local sandbox repo)

## Documentation rules

- the repo is public: in docs and examples use placeholders (`mycompany`, `my-project`, `123456789012`), not real ids
- README inputs table must match `action.yml` inputs (names, defaults; code-level defaults are explained in the description)
- a new input or artifact type also updates: README (inputs, "Artifact types" table), `docs/artifact-types/`,
  `docs/features/dev-release.md` (inputs respected by dev-release), `docs/features/idempotency.md`, `docs/troubleshooting.md` (steps)
- new artifact type checklist: `docs/contribution.md`. After the first real release with a new feature add a row in `docs/test-coverage.md`
- examples in `docs/examples/` mirror real repos (env-api, tt-web, envctl, java-parent, gha-release); when a real repo changes,
  check that the example and the doc text about it still agree. Examples call `agilecustoms/release@v6` with explicit inputs
  (or `mycompany/gha-release`), not agilecustoms internals
- a high-level rule (best-practices.md, authorization.md, README) and a specific doc must agree: fix both or neither
