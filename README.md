# About
Reusable GitHub Action `gha-release`
1. Generate new version
2. Login to AWS
3. Upload artifacts to S3
4. Push two tags: new (generated) version and 'latest'

Note: if upload fails OR some other error between step 3 and 4 - we'll get a new version that nobody knows about
- it is better than having git tag promising something that you can not get

## Test via 'test' workflow
1. Make a branch 'feature' (this repo unlikely incur many changes)
2. Push branch and get feedback
3. Once satisfied, revert any debug changes and merge to `main` 
