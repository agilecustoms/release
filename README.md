# About
Reusable GitHub Action `gha-release`
1. Generate new version
2. Upload artifacts to S3
3. Push two tags: new (generated) version and 'latest'

## Test via 'test' workflow
1. Make a branch 'feature' (this repo unlikely incur many changes)
2. Push branch and get feedback
3. Once satisfied, revert any debug changes and merge to `main` 
