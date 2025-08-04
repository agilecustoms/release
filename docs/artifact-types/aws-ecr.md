### publish in AWS ECR

First you build docker image, and then you release it with this action.
Same as git tags, when you release version `1.2.3` with commit message `fix: JIRA-123`,
new docker image will be tagged as `1.2.4`, and tags `1`, `1.2` and `latest` will be overwritten to point to the same image as `1.2.4`
```yaml
steps:
  - name: Docker build
    run: docker build

  - name: Release
    uses: agilecustoms/release@v1
    with:
      aws-account: ${{ vars.AWS_ACCOUNT_DIST }}
      aws-region: us-east-1
      aws-role: 'ci/publisher'
      aws-ecr: true
```

**dev-release** works smoothly with ECR: Docker image gets published with tag equal to branch name.
ECR allows you to configure lifecycle rules by tag prefix, so if you adopt `dev/` prefix for your dev-release branches,
then you can set up ECR lifecycle rule to delete images with prefix `dev-` after 30 days automatically!