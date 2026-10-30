#!/usr/bin/env bash
# Publish package in npmjs. On re-run, ignore "version already exists" (published by the previous attempt)
# Inputs (env): NPM_VISIBILITY (public/private), CHANNEL (npm dist-tag)
set -eo pipefail

set +e
npm publish --access "$NPM_VISIBILITY" --tag "$CHANNEL" 2>&1 | tee /tmp/npm_publish.log
error_code=${PIPESTATUS[0]}
set -e

if [ "$error_code" -ne 0 ] && [ "$GITHUB_RUN_ATTEMPT" != "1" ]; then
  if grep -q "You cannot publish over the previously published versions" /tmp/npm_publish.log; then
    echo "Ignore error 'version already exist' for run attempt $GITHUB_RUN_ATTEMPT"
    exit 0
  fi
fi
exit "$error_code"
