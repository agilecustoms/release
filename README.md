# About
Reusable GitHub Action `gha-release`
1. Generate new version
    - based on latest tag + git commit message: #major, #minor, #patch
2. Upload artifacts to S3 (if any)
    - Artifacts need to be in `dist` directory
3. Push two tags: new (generated) version and 'latest'
4. Send new version to central repository (gitops)
    - if `input.dev_release == true` then do nothing
    - if repo name has no `-` then do nothing
    - get current repo prefix like `tt-message` => `tt` and then try to find `{prefix}-gitops`.
      If not found (like `gha-prepare-terraform`, `java-parent`, `db-evolution-runner`) then do nothing. If found - send update in this repo.
      That means some microservices as `db-evolution-runner` will be not automatically sent to gitops and need to be updated manually

Note: if upload fails OR some other error between step 3 and 4 - we'll get a new version that nobody knows about
- it is better than having git tag promising something that you can not get

## Test via 'test' workflow
1. Make a branch 'feature' (this repo unlikely incur many changes)
2. Push branch and get feedback
3. Once satisfied, revert any debug changes and merge to `main` 
