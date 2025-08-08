# AWS Authorization

Given
- AWS account hosting artifacts. _Recommendation: have a dedicated account, not prod_
- in this account you already have S3 bucket / ECR repository / CodeArtifact repository

You need an IAM role and then "hook it up" in GitHub Action, see below:

## IAM Role

Legacy approach (not supported): have a service account (user) with long-lived access keys and secrets stored in GitHub secrets

Modern approach: use OpenID Connect (OIDC) between GitHub and AWS, so that GitHub workflows can assume an IAM role in AWS account.
If you never used it, do not worry, it is easier than you think:
1. The only new step compared to the legacy approach is to create [IAM OIDC provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html).
If you use Terraform, just use this resource:
```hcl
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}
```
2. Create IAM policy with permissions to publish artifacts or use terraform module [terraform-aws-ci-publisher](https://registry.terraform.io/modules/agilecustoms/ci-publisher/aws/latest)
3. Create an IAM role with trust policy's principal set to the OIDC provider from step 1 and permission policy from step 2

_Recommended name for the role is `ci/publisher`_

[complete example using Terraform](https://github.com/agilecustoms/terraform-aws-ci-publisher?tab=readme-ov-file#how-to-create-a-role-with-this-policy)

## Use in GitHub Action

1. (recommendation) Place AWS account where artifacts stored in GitHub org variable such as `AWS_ACCOUNT_DIST`
2. GitHub Action Job needs to have permissions `id-token: write` to allow GitHub to request an OIDC token
3. Finally, pass AWS account ID, region and role via inputs to the action

```yaml
jobs:
  Release:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write
    steps:
      # ...
      - name: Release
        uses: agilecustoms/release@v1
        with:
          aws-account: ${{ vars.AWS_ACCOUNT_DIST }}
          aws-region: us-east-1
          aws-role: 'ci/publisher'
          # any combination of: aws-* inputs pointing to S3 / ECR / CodeArtifact
```

_Note: by default, a Job has permissions `contents: read`, since you need `id-token: write`, the default one is overridden,
so if you need to read repository content, make sure to add `contents: read` explicitly_
