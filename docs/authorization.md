# Authorization and security

In this document we'll cover the following topics:
- [GitHub Authorization and security](#github-authorization-and-security)
- [AWS Authorization](#aws-authorization)
- [dev-release security](#dev-release-security)
- [Advanced](#advanced)

## GitHub Authorization and security

These are characteristics for a typical GitHub project ([TLDR](#final-gh-repo-setup)):
- at least one protected branch such as `main` or `master`: all changes in these branches must be made via PRs
- release workflow creates new tag (for now forget about automated changes such CHANGELOG.md)
- developer can push changes in non-protected branch such as `feature/login`

Now look at the last two points: there is a hidden **security implication**. For a developer to do their job,
you need to grant them a `contents: write` permission, but this permission also allows to push arbitrary git tags!
Solution? Use the GitHub feature "tag ruleset" to prohibit all tags creation, update and deletion.
Now we need to grant a permission to bypass this rule to a release workflow so it can create tags!

This is where PAT ([Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)) 
comes into play: in this "tag ruleset" you configure a Role that can bypass it,
then a person possessing this role needs to create a PAT to use it in the release workflow:
- either a fine-grained PAT with `Contents "Read and write"`
- or classic PAT with `repo` scope

Next big question: **how do you ensure this PAT is not compromised**?
Like when a developer makes a mistake/malicious workflow in a feature branch to print PAT in file and then upload it as artifact.
There are two solutions:

For private/internal repositories you can use **push ruleset** to prohibit any changes in `.github/**/*`.
This restriction is even stronger than `CODEOWNERS`: GitHub will reject any push that attempts to change workflow files!
So you can put the PAT in an organization-level secret and access it from all repos. Problem 1: if any repo misses this rule,
the token still can leak. Problem 2: it is not scalable — only admins can change `.github/**/*` files,
other developers can't even create a PR for improvements!

The better option is to create a **GitHub environment** (lets call it `release`) and put PAT in this environment secret.
Then configure this environment so that only protected branches can use it.
Finally, in the release workflow (assuming it is run on push in protected branch) you specify `environment: release` to access a secret

`agilecustoms/release` action takes this PAT via env variable `GH_TOKEN`:
```yaml
jobs:
  Release:
    environment: release
    # ...
    steps:
      # ...
      - name: Release
        uses: agilecustoms/release@v1
        env:
          GH_TOKEN: ${{ secrets.GH_TOKEN }} # secret can have any name, use `GH_TOKEN` for consistency
```

One problem remains: what if two "bad" developers act together: one creates a PR to change release workflow to print PAT,
and second approves it? To mitigate this risk you configure `CODEOWNERS` so that only trusted people can approve changes in `.github/**/*`

### Final GH repo setup

1. create "branch ruleset" to protect `main` branch: require PRs, require reviews, require status checks, etc
2. create "tag ruleset" to prohibit all tags creation, update and deletion
3. create a PAT to bypass rules 1. and 2.
4. create environment `release` associated with protected branch(es) and put PAT in this environment secret
5. (additionally) create `CODEOWNERS` file to protect `.github/**/*` files

At this point GitHub security should be in a good shape. Only problem — it is quite a lot of work: configure branch protection rules,
tag protection rules, create environment and configure its access from protected branches, configure CODEOWNERS.
In the world of microservices it is quite common to have 50+ repositories, so it is a lot of work to do it manually.
You can automate this via provisioning GitHub repos via Terraform (there is a [GitHub provider](https://registry.terraform.io/providers/integrations/github/latest/docs)).
Fall 2025 I plan to release a Terraform module that will do all this work for you

## AWS Authorization

`agilecustoms/release` supports different types of artifacts. Read this section if you release
any of these: AWS S3, ECR, CodeArtifact. This is in addition to GitHub authorization described above

Given AWS account hosting artifacts. _Recommendation: have a dedicated account (not Prod) lets call it Dist_.
In this account you already have S3 bucket / ECR repository / CodeArtifact repository.
Now you need an IAM role that can be assumed from GitHub Action

Legacy approach (not supported): have a service account (user)
with long-lived `ACCESS_KEY_ID`/`SECRET_ACCESS_KEY` stored in GitHub secrets

Modern approach: use [OpenID Connect](https://github.com/aws-actions/configure-aws-credentials?tab=readme-ov-file#quick-start-oidc-recommended)
(OIDC) between GitHub and AWS, so that GitHub workflows can assume an IAM role in AWS account.
Here is a [complete example using Terraform](https://github.com/agilecustoms/terraform-aws-ci-publisher?tab=readme-ov-file#how-to-create-a-role-with-this-policy)

Step-by-step explanation:
1. The only new step compared to the legacy approach is to create [IAM OIDC provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html).
   If you use Terraform, just use this resource:
```hcl
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}
```
2. Create IAM policy (recommended name `ci/publisher`) with permissions to publish artifacts
    or use terraform module [terraform-aws-ci-publisher](https://registry.terraform.io/modules/agilecustoms/ci-publisher/aws/latest)
3. Create an IAM role (recommended name `ci/publisher`)
   with trust policy's principal set to the OIDC provider from step 1 and permission policy from step 2

### Use IAM role in GitHub Action

1. (recommendation) Place AWS account number (where artifacts stored) in GitHub org variable such as `AWS_ACCOUNT_DIST`
2. GitHub Action Job needs to have permissions `id-token: write` to allow GitHub to request an OIDC token
3. Finally, pass AWS account ID, region and role via inputs to the action

```yaml
jobs:
  Release:
    runs-on: ubuntu-latest
    environment: release
    permissions:
      contents: read # for checkout
      id-token: write # to assume AWS role via OIDC (requires generation of JWT token)
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

## dev-release security

`agilecustoms/release` has major feature [dev-release](./features/dev-release.md).
It is basically a release self-service for developers.
Use of this feature assumes all security measures described above are already in place!
Additional dev-release specific security considerations are placed in the [dev-release security](./features/dev-release.md#security) section

## Advanced

TBD

### persist-credentials: false

```yaml
jobs:
  Release:
    runs-on: ubuntu-latest
    environment: release
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          persist-credentials: false

      - name: Release
        uses: agilecustoms/release@v1
        with:
          GH_TOKEN: ${{ secrets.GH_TOKEN }} # your PAT 
```

### use PAT with actions/checkout

You have a choice **how to pass this PAT**:

Option 1 (recommended): pass PAT in `agilecustoms/release` env variable `GH_TOKEN`
```yaml
- name: Release
  uses: agilecustoms/release@v1
  env:
     GH_TOKEN: ${{ secrets.GH_TOKEN }}
```

Option 2: pass PAT in `github/checkout` `token` parameter
```yaml
- name: Checkout
  uses: actions/checkout@v4
  with:
    token: ${{ secrets.GH_TOKEN }}
```

You must use Option 1 to make a GH release (input `release-gh` is `true` by default).
If not use GH releases, you can choose Option 1 or 2, but Option 1 is still recommended —
it limits write access only to one step (`agilecustoms/release`).
In Option 2 all steps (after checkout) effectively have permission to commit and push in protected branch

Secret name could be different, I use `GH_TOKEN` for consistency with env variable
