#!/usr/bin/env bash
# Tag local Docker image '$SERVICE' with all versions and push it in ECR
# Inputs (env): SERVICE, ECR_REGISTRY, TAGS (space-separated, e.g. "1.2.3 1.2 1 latest"), DEV_RELEASE
set -eo pipefail

ecr_image="$ECR_REGISTRY/$SERVICE"
read -ra image_tags <<< "$TAGS"

if [ "$DEV_RELEASE" != "true" ]; then
  image_ids=()
  for tag in "${image_tags[@]}"; do
    image_ids+=("imageTag=$tag")
  done
  AWS_PAGER="" aws ecr batch-delete-image --repository-name "$SERVICE" --image-ids "${image_ids[@]}" || true
fi

for tag in "${image_tags[@]}"; do
  docker tag "$SERVICE" "$ecr_image:$tag"
done
docker push --all-tags "$ecr_image"
