# Idempotency

1. Validate
2. Release generation
    1. generate a new version based on the latest SemVer tag + git commit messages
    2. generate release notes (write in /tmp file)
    3. update CHANGELOG.md
3. Login in AWS
4. Prepare
    1. update version in `package.json` (npm), `pom.xml` (maven), `pyproject.toml` (Python)
    2. run a custom script to update arbitrary files
5. Publish artifacts
    1. AWS S3 - upload files in S3 bucket, files need to be in `./s3` directory
    2. AWS ECR - publish Docker image in ECR repository
    3. AWS CodeArtifact maven - publish maven package in CodeArtifact repository
    4. npmjs - publish npm package in public npmjs.com repository
6. Git commit/tag/push
    1. commit changes from step 4
    2. besides SemVer 'major.minor.patch', also add floating tags 'major', 'major.minor' and 'latest'
    3. atomically push commit and refs (tags and notes) to the remote repository
7. Create GitHub release
8. Print summary

### Idempotency

This GH action does three modify operations: "Publish artifacts", "Git push" and "GitHub release".
Order is important to recover from failures:

- **Publish artifacts** goes first as it is the most complex (highest chances to fail).
  It is idempotent, so if a later step fails, it is safe to re-run "Publish artifacts".<br>
  _Note: some publish commands are not idempotent (npm publish), so as workaround just swallow 'same version already exists' type of errors
  if it is already not first workflow run (use `${{ github.run_attempt }}`)_

- **Git push** goes next as it is much simpler and less likely to fail.
  And it is _not_ idempotent: given "Git push" succeeds, an attempt to run it again will cause new tags creation!

- **GitHub release** goes last, as it is optional. It is also very simple — just one command
  (provided all release notes/files are generated on previous steps).
  If it fails, you can create release manually through GitHub UI