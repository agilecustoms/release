#!/usr/bin/env bash
# Finalize version and tags
# Inputs (env): DEV_RELEASE, GEN_VERSION, GEN_GIT_TAGS, GEN_TAGS (GEN_* - outputs of release-gen step)
# Outputs: version, git_tag, git_tags, tags
set -eo pipefail

if [ "$DEV_RELEASE" = "true" ]; then
  version="${GITHUB_REF#refs/heads/}"
  version="${version//\//-}" # refs/heads/feature/abc -> feature-abc
  git_tags="$version"
  tags="$version"
else
  # version and tags are bare (1.2.3) - used in manifests, S3 path, Docker tag
  # git_tags have tag-format applied (v1.2.3 v1.2 v1), first one is the git tag of this release
  version="$GEN_VERSION"
  git_tags="$GEN_GIT_TAGS"
  tags="$GEN_TAGS"
fi
git_tag="${git_tags%% *}"

{
  echo "version=$version"
  echo "git_tag=$git_tag"
  echo "git_tags=$git_tags"
  echo "tags=$tags"
} >> "$GITHUB_OUTPUT"
