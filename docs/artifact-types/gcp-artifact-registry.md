# publish in Google Artifact Registry

_Note: examples use shared patterns covered in [Best practices](../best-practices.md) and [Authorization and security](../authorization.md)
("release" GitHub environment holds `GH_TOKEN` secret)_

- [Docker image for Cloud Run](#docker-image-for-cloud-run)
- [Authorization: Workload Identity Federation](#authorization-workload-identity-federation)
- [Tags](#tags)
- [dev-release](#dev-release)

## Docker image for Cloud Run

Example: Python (FastAPI) service, image is built from `package/` directory (app + dependencies installed for linux/amd64)

```
<repo root>
├── .github/
├── src/
├── package/      <-- built in CI Build job, passed to Release job as artifact
├── Dockerfile    <-- just 'COPY package /app', no build inside
└── pyproject.toml
```

```yaml
jobs:
  Build:
    # ... lint, test, build package/
      - name: Upload artifacts
        if: github.ref == 'refs/heads/main'
        uses: actions/upload-artifact@v7
        with:
          name: package
          path: package/

  Release:
    if: github.ref == 'refs/heads/main'
    needs: Build
    runs-on: ubuntu-latest # Docker is needed
    environment: release
    permissions:
      contents: read
      id-token: write # GitHub OIDC token for Workload Identity Federation
    steps:
      - name: Checkout
        uses: actions/checkout@v7

      - name: Download artifacts
        uses: actions/download-artifact@v8
        with:
          name: package
          path: package

      # 'docker push' must be in the same job as image build: image can't be passed between jobs
      - name: Docker build
        run: docker build -t my-service .

      - name: Release
        uses: agilecustoms/release@v6
        with:
          gcp-artifact-repository: my-repo
          gcp-project: my-project
          gcp-region: us-east1
          gcp-service-account: ci-publisher
          gcp-workload-identity-provider: projects/123456789012/locations/global/workloadIdentityPools/github/providers/github
        env:
          GH_TOKEN: ${{ secrets.GH_TOKEN }}
```

Local image name must be equal to the repo name (`my-service` for repo `my-company/my-service`), same as for [ECR](./aws-ecr.md).
`agilecustoms/release`:
1. generates the next version based on commit messages
2. logs in Google Cloud with [google-github-actions/auth](https://github.com/google-github-actions/auth) as service account
   `ci-publisher@my-project.iam.gserviceaccount.com` (no keys, see below)
3. updates version in `pyproject.toml` and `uv.lock` (if present)
4. pushes Docker image `us-east1-docker.pkg.dev/my-project/my-repo/my-service` with tags `1.2.3`, `1.2`, `1` and `latest`
5. pushes git commit and tags to the remote repository

## Authorization: Workload Identity Federation

Same idea as AWS OIDC: GitHub OIDC token is exchanged for a short-lived token of a service account, no long-lived keys.
Input `gcp-service-account` is a short name, full one is `{gcp-service-account}@{gcp-project}.iam.gserviceaccount.com`
(the AWS counterpart is input `aws-role`).
Resources in Google Cloud (Terraform):

```hcl
# pool + provider: trust GitHub OIDC tokens of your organization only
resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
  attribute_mapping = {
    "google.subject"        = "assertion.sub"
    "attribute.environment" = "assertion.environment"
  }
  attribute_condition = "assertion.repository_owner_id == '123456'" # your GitHub organization id
}

resource "google_service_account" "ci_publisher" {
  account_id = "ci-publisher"
}

# push images in one repository
resource "google_artifact_registry_repository_iam_member" "ci_publisher" {
  repository = "my-repo"
  location   = "us-east1"
  role       = "roles/artifactregistry.writer"
  member     = google_service_account.ci_publisher.member
}

# only jobs in GitHub environment "release" (protected branches) can act as ci-publisher
resource "google_service_account_iam_member" "ci_publisher_github" {
  service_account_id = google_service_account.ci_publisher.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.environment/release"
}
```

Input `gcp-workload-identity-provider` is the full name of the provider. Unlike AWS (where `role-to-assume` is enough),
Google needs it explicitly: a project can have many pools, each with many providers

## Tags

Repository must have mutable tags (default): floating tags `1.2`, `1` and `latest` move to the new image on each release.
Unlike [ECR](./aws-ecr.md), existing tags are not deleted before push: Artifact Registry moves a tag to the pushed image.
Re-running a release pushes the same tags again, so the release is idempotent.
Old images can be removed by [cleanup policies](https://cloud.google.com/artifact-registry/docs/repositories/cleanup-policy),
e.g. keep N most recent versions and delete the rest older than 30 days

## dev-release

Not tested yet. Technically [dev-release](../features/dev-release.md) pushes an image with tag equal to the branch name
(`feature/login` -> `feature-login`), but it needs a service account that trusts non-protected branches
(in the example above `ci-publisher` trusts only environment `release`).
Cleanup policies support tag prefixes, so `feature-*` images can be removed automatically
