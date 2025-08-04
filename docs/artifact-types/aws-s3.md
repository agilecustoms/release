### publish in AWS S3

Convention: there should be `s3` directory in cwd. All content of this directory will be uploaded in S3 bucket<br>
Ex: if the latest tag is '1.2.3' and single commit on top of it `fix: JIRA-123`, then files will be uploaded to `aws-s3-bucket/aws-s3-bucket-dir/1.2.4`
Also files will be uploaded in dirs `/1`, `/1.2` and `/latest` - previous content of these dirs will be cleaned up
```yaml
steps:
  - name: Release
    uses: agilecustoms/release@v1
    with:
      aws-account: ${{ vars.AWS_ACCOUNT_DIST }}
      aws-region: us-east-1
      aws-role: 'ci/publisher' # default
      aws-s3-bucket: 'mycompany-dist'
```
Additionally, you can specify `aws-s3-dir`, then files will be uploaded to `s3-bucket/{aws-s3-dir}/{current-repo-name}/{version}/{files from ./s3 directory}`<br>
Convention: publishing of all AWS types of artifacts require `aws-account`, `aws-region` and `aws-role` parameters

**dev-release** will publish files in `s3-bucket/{aws-s3-dir}/{current-repo-name}/{branch-name}/` directory.
Each S3 file will be tagged with `Release=false`, so you can set up lifecycle rule to delete such files after 30 days!