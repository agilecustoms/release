# Dev release

- [motivation](#motivation)
- [configuration](#configuration)
- [supported artifact types](#supported-artifact-types)
- [security](#security)
- [risk analysis](#risk-analysis)

Besides normal releases, prereleases, and maintenance releases, this action supports a special type of release called **dev-release**.
It sounds similar to prerelease, so let's clarify the difference:

**prerelease** is an industry standard, though some tools use different terms
like "prerelease" (GitHub), distribution tags (npm), suffix "-SNAPSHOT" (maven), suffixes "-beta", "rc" (Gradle, NuGet, PyPI, pip).
Idea: release a version widely available for testing and with potential to become the next major release

**dev-release** is a way to overcome the inability to spin up the entire env locally.
It allows you to temporarily release a version (= branch name), so that you can deploy it in sandbox or dev environment for testing or POC

The table below shows a comparison of different release types:

| Name                        | normal release and maintenance release        | prerelease                                    | dev-release              |
|-----------------------------|-----------------------------------------------|-----------------------------------------------|--------------------------|
| intention                   | use in production                             | beta testing                                  | dev testing              |
| best use for                | software packages and deployable apps         | software packages and deployable apps         | deployable apps          |
| adoption                    | widely                                        | widely                                        | popular in enterprise    |
| version generation          | "conventional commits" or "version-bump"      | "conventional commits" or "version bump"      | version = branch name    |
| auto deletion               | ❌️                                            | ❌️                                            | ✅                        |
| number of developers        | many                                          | many                                          | typically one            |
| release notes and changelog | ✅                                             | ✅                                             | ❌️                       |
| floating tags               | major, minor, latest                          | alpha / beta / rc                             | ❌️                       |
| trigger                     | push in protected branch (including PR merge) | push in protected branch (including PR merge) | Manual workflow dispatch |


Dev release allows publishing artifacts temporarily for testing purposes:
you push your changes to the feature branch, the branch name becomes this dev-release version:
- SemVer is _not_ generated
- no automated pushes, so no need for PAT
- no git tags created, files in branch addressable by branch name
- `/` gets replaced with `-`, so branch `feature/login` gives version `feature-login`
- parameter `dev-branch-prefix` (default value is `feature/`) enforces branch naming for dev releases.
  This is needed for security and automatic resource disposal. Set to an empty string to disable such enforcement (not recommended)
- for each [artifact type](./../artifact-types/index.md), dev-release might have different semantics,
  see the "dev-release" section for each artifact type

dev-release workflow blueprint:

```yaml
name: Dev Release

on:
  workflow_dispatch:

jobs:
  # ...
  Release:
    # ...
    steps:
      # ...
      - name: Release
        uses: agilecustoms/release@v4
        with:
          aws-account: ${{ vars.AWS_ACCOUNT_DIST }}
          aws-region: us-east-1
          aws-role: 'ci/publisher-dev' # see "Security" section below
          aws-s3-bucket: 'mycompany-dist'
          dev-release: true
          dev-release-prefix: 'feature/' # default
```

Complete examples:
- [AWS S3](../examples/env-api/.github/workflows/release-dev.yml), see [details](../artifact-types/aws-s3.md#dev-release)
- [AWS ECR](../examples/env-cleanup/.github/workflows/release-dev.yml), see [details](../artifact-types/aws-ecr.md#dev-release)

## Motivation

_How did we live without a dev-release before?
We do use microservices in our team, and we just have a CI/CD pipeline that can build a feature branch and deploy it to a dev environment.
So we do not need dev-release, right?_

Build-and-deploy is kind of a "shortcut" and it may work in simple scenarios.
The reality is that a system consists of multiple services, and true deployment takes a combination of services!
Imagine a system that consists of two services A and B, and there is a repo C storing the current combination: `A@v1.0`, `B@v1.1`.
And only C has a "Deploy" button!
Now, you want to make a change in service A and test it, but since the only way to deploy a system is to deploy both services together,
you must create a temporary release of A. This is a dev-release!

## Configuration
 
`dev-release` mode takes precedence over normal release modes ("conventional commits", "version-bump" and "explicit version").
When `dev-release` is set to `true` it ignores most of the parameters that are used for normal releases.
These are only parameters respected by dev-release:
`aws-account`, `aws-ecr`, `aws-region`, `aws-role`, `aws-s3-bucket`, `aws-s3-dir`, `dev-branch-prefix`

There is no error if `dev-release` used with incompatible parameter (like `tag-format` or `floating-tags`).
General principle: ignore unused parameters,
so that you can have one [corporate gha wrapper](../best-practices.md#company-specific-gha-release-wrapper)
for `agilecustoms/release`

Only parameter that conflicts with `dev-release` is `version` as it looks like a complete mistake

## Supported artifact types

_Some software package tools like npm and python Poetry only support SemVer versions, so no dev-release.
Maven, on the other hand, allows an arbitrary version format.
The problem is that there is no way to distinguish normal release from dev-release.
And also, there is no way to automatically delete such dev-release artifacts.
So I (author) decided to not allow dev-release for CodeArtifact completely_

Artifact types that support dev-release:
[AWS S3](../artifact-types/aws-s3.md#dev-release),
[AWS ECR](../artifact-types/aws-ecr.md#dev-release) and
[git](../artifact-types/git.md#dev-release) (just because you can create a feature branch)

## Security

Dev-release mode brings self-service capabilities but also brings security risks

_You can't guarantee dev-release security if anybody can assume your 'ci/publisher' role.
Or if anybody can use powerful GH PAT to make arbitrary Git changes and then run a malicious workflow on the main branch.
In this section we assume you already have a secure GitHub setup and AWS authorization, see [Authorization and security](../authorization.md)_

Now lets focus on risks coming specifically from dev-release. Developers may try to use dev-release workflow to:
1. _Create_ unverified artifact that looks like normal
2. _Update_ (override) existing production artifact
3. _Delete_ production artifact

Down below these three risks are referred as _Create_, _Update_, _Delete_.
To mitigate these risks, we'll need two separate IAM roles:
- `ci/publisher` for normal releases (trust only protected branches), with full permissions to publish artifacts to S3, ECR and CodeArtifact
- `ci/publisher-dev` for dev-release (trust any branch), with limited permissions to publish artifacts to S3 and ECR

IAM role has two parts: trust policy and permission policy

**permission policy** for both roles can be created with terraform module
[ci-publisher](https://registry.terraform.io/modules/agilecustoms/ci-publisher/aws/latest).
For dev policy you would use input `dev = true` and it will create a limited policy for dev-release.
Additionally, you need to configure lifecycle rules to automatically delete dev-release artifacts.
Below is a breakdown of permissions needed:

| Name              | publisher                              | publisher-dev                             |
|-------------------|----------------------------------------|-------------------------------------------|
| Role CodeArtifact | Allow PublishPackageVersion            |                                           |
| S3 bucket policy  | delete "Release=false" in 7 days       | _same_                                    |
| Role S3 Create    | Allow PutObject                        | Allow PutObject w/ tag Release=false      |
| Role S3 Update    | Allow PutObject                        | Deny PutObjectTagging w/ tag Release=true |
| Role S3 Delete    | Allow DeleteObject                     |                                           |
| ECR repo policy   | delete "feature-" in 7 days            | _same_                                    |
| Role ECR Create   | Allow PutImage                         | Allow PutImage                            |
| Role ECR Update   | Allow PutImage, Allow BatchDeleteImage |                                           |
| Role ECR Delete   | Allow BatchDeleteImage                 |                                           |

**trust policy** for both roles going to use same OIDC provider, but different `sub` condition.
`ci/publisher-dev` role can trust any branch or only branches starting with `feature/`, up to you.
For `ci/publisher` role you might think you need to trust only protected branches!
But in GitHub if a workflow uses an environment — it takes precedence in OIDC token,
so on AWS side instead of "trust main branch" you would need to configure "trust release environment" type of trust policy.
See [terraform-aws-ci-publisher](https://github.com/agilecustoms/terraform-aws-ci-publisher) for trust policy examples.
See [GitHub Authorization](../authorization.md#github-authorization-and-security) why environment is needed in the first place

## Risk analysis

With these permission policies the risk mitigation looks like this:

| Name | create unverified | update  | delete   |
|------|-------------------|---------|----------|
| S3   | ⚠️ risk           | ⚠️ risk | ⚠️ risk  |
| ECR  | ⚠️ risk           | ✅ safe  | ✅ safe   |

Why create unverified is marked as ⚠️? Because IAM policy itself can't 100% prevent creating unverified artifact.
Assume you have a role `ci/publisher-dev` that allows to create artifacts in S3 and ECR,
and this role can be assumed from any feature branch. The risk is that a developer can create a feature branch and
craft a workflow where they assume `ci/publisher-dev` role and create artifact manually, not via `agilecustoms/release` action.
To mitigate this risk, you need to use GitHub rules that any changes in `.github/**/*` must be approved by `CODEOWNERS`

Next, let's cover worst case scenarios. Assume you have policies `ci/publisher` and `ci/publisher-dev` generated by
terraform module [ci-publisher](https://registry.terraform.io/modules/agilecustoms/ci-publisher/aws/latest). Role `ci/publisher`
is secure by environment trust, but role `ci/publisher-dev` can be assumed on any branch, and you _do not have CODEOWNERS_.
What can a malicious developer do?

### S3 Risks

Feature branch name is used as suffix for dev-release artifacts, so `ci/publisher-dev` can only put objects at path `mycompany-dist/*/feature*`
Imagine a software product which release consists of multiple files like this:
```
<bucket>/myservice/v1.2.3/
├── feature/
│   └── file      <-- vulnerable
├── other-dir/
│   └── file      <-- secure
└── file          <-- secure
```
In this case (again if no `CODEOWNERS`) a malicious developer can create a feature branch with a custom workflow
where they assume `ci/publisher-dev` role and put objects into `s3://mycompany-dist/myservice/v1.2.3/feature/*`.
So the risks are:

1. during a certain period of time a malicious file `s3://mycompany-dist/myservice/v1.2.3/feature/file`
   is stored (and served!) among normal files
2. malicious developer can put file `s3://mycompany-dist/myservice/v1.2.3/feature/file2`.
   In this case it is not an override, it is a new file. Might not be a problem if no one use it, or might be a problem
   if your software does something with all files in `feature/` directory
3. According to IAM policy, the file can be put only with tag `Release=false` and according to S3 lifecycle rule,
   it will be auto-deleted in 7 days, so a malicious developer can effectively _delete_ normal files in `feature/` directory

### ECR Risks

Typical ECR repository is immutable, so if you do not have `CODEOWNERS`, a malicious developer can create a feature branch
with a custom workflow where they assume `ci/publisher-dev` role and put images into ECR repo
with arbitrary tags (not starting from `feature-`), like `v2.0.0` or `v1.2.4` (which looks like a legit bug fix)

How to protect against such a malicious version (besides `CODEOWNERS`)?
In your deployment pipelines use git tags as a source of truth!
- If there is a git tag — you can trust the corresponding ECR tag
- If a git tag is not backed by ECR tag — deploy will just fail.
  `agilecustoms/release` first publishes artifacts and then pushes git tags. So this situation is only possible if ECR tag was deleted by admin later!
- What if there is an orphan ECR tag? It is possible if the "publish" phase succeeded, but "git push" failed.
  You can investigate pipeline failure and retrigger it but never deploy a half-baked release (with no git tags)
