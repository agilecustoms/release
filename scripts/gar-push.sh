#!/usr/bin/env bash
# Tag local Docker image '$SERVICE' with all versions and push it in Google Artifact Registry
# Inputs (env): SERVICE, GCP_ARTIFACT_REGISTRY (e.g. us-east1-docker.pkg.dev/my-project/my-repo), GCP_ACCESS_TOKEN,
#  TAGS (space-separated, e.g. "1.2.3 1.2 1 latest")
# Unlike ECR, existing tags are not deleted before push: Artifact Registry moves a tag to the new image (repo with mutable tags)
set -eo pipefail

registry_host="${GCP_ARTIFACT_REGISTRY%%/*}" # us-east1-docker.pkg.dev
echo "$GCP_ACCESS_TOKEN" | docker login -u oauth2accesstoken --password-stdin "https://$registry_host"

image="$GCP_ARTIFACT_REGISTRY/$SERVICE"
read -ra image_tags <<< "$TAGS"
for tag in "${image_tags[@]}"; do
  docker tag "$SERVICE" "$image:$tag"
done
docker push --all-tags "$image"
