# About
Reusable GitHub Action `gha-release`
1. Generate new version
    - based on latest tag + git commit message: #major, #minor, #patch
2. Update version in code (`package.json`, `pom.xml`) and commit
   1. maven (java-parent)
   2. npm (envctl)
3. Git push
   1. push two tags: new (generated) version and 'latest'
   2. push changes from step 2
4. Publish artifacts
   1. S3 (tt-message, tt-web, tt-auth, db-evolution-runner, env-api). Files need to be in `s3` directory. Supports dev-release
   2. Docker - ECR (env-cleanup)
   3. maven - CodeArtifact (java-parent)
   4. npm - npmjs.com (envctl)
5. Send new version to central repository `tt-gitops` (hardcoded)
   - do it only if `input.dev_release == false` and current repo name starts with `tt-` (hardcoded) 
   - if `input.dev_release == true` then do nothing
   - (future) get current repo prefix (like `tt-message` => `tt`) and then try to find `{prefix}-gitops`.
     If not found (like `gha-prepare-terraform`, `java-parent`, `db-evolution-runner`) then do nothing. If found - send update in this repo.
     That means some microservices as `db-evolution-runner` will be not automatically sent to gitops and need to be updated manually

Note: first I do git "Git push" and then "Publish artifacts", so that if publish fails, I can re-run release workflow.
Ofcourse the price is dangling git tag. If publish fails painfully, we can easily roll back git tag!

## Test via 'test' workflow
1. Make a branch 'feature' (this repo unlikely incur many changes)
2. Push branch and get feedback
3. Once satisfied, revert any debug changes and merge to `main` 
