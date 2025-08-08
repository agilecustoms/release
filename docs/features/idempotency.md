# Idempotency

Failures happen. What to do if a release action fails?

`agilecustoms/release` consists of several steps with three **modify** operations at the end:

1. Validate
2. Release generation
    1. generate a new version
    2. generate release notes (write in /tmp file)
    3. update CHANGELOG.md
3. Login in AWS
4. Prepare
    1. update version in `package.json` (npm), `pom.xml` (maven), `pyproject.toml` (Python)
    2. run a custom script to update arbitrary files
5. **Publish artifacts** (currently AWS S3/ECR/CodeArtifact, npm)
6. **Git push**
    1. commit changes from step 4
    2. add version tag, move floating tags
    3. atomically push commit and refs (tags and notes) to the remote repository
7. **GitHub release**
8. Print summary

Failure on early steps (1-4) is not critical, just fix the issue and re-run the workflow

Then there are three **modify** operations and their consequences/remediation in case of failure:

**Publish artifacts** goes first as it is the most complex (highest chances to fail).
It is _idempotent_, so if a later step fails, it is safe to re-run "Publish artifacts".<br>
_Note: some publish commands are not idempotent (npm publish),
so as workaround they just swallow 'same version already exists' type of errors
if it is not the first workflow run (use `${{ github.run_attempt }}`)_

**Git push** goes next as it is much simpler and less likely to fail.
It is _atomic_, but not _idempotent_. If it fails — it is safe to rerun (bcz previous step is _idempotent_)

**GitHub release** goes last because it needs a git tag to already exist.
It is also very simple — just one command (actual release notes are generated at step 2).
If it fails, **do not re-run the workflow** as it may create a new version!
Why _may_? It depends on your [version generation](./version-generation.md) approach.
Best remedy - get release notes from `CHANGELOG.md` and create missing release manually via GitHub UI
