#!/usr/bin/env bash
# Publish maven artifacts to CodeArtifact. On re-run, ignore "version already exists" (published by the previous attempt)
set -eo pipefail

MVN=mvn
if [[ -x ./mvnw ]]; then MVN=./mvnw; fi
set +e
# tee (not $(...)) to stream the log live, file is for the 409 check below
"$MVN" --no-transfer-progress deploy -Dmaven.main.skip=true -Dmaven.test.skip=true \
  -Dcheckstyle.skip=true -Denforcer.skip=true -Djacoco.skip=true 2>&1 | tee /tmp/mvn_deploy.log
error_code=${PIPESTATUS[0]}
set -e
if [ "$error_code" -ne 0 ] && [ "$GITHUB_RUN_ATTEMPT" != "1" ]; then
  if grep -q "status code: 409" /tmp/mvn_deploy.log; then
    echo "Ignore error 'version already exist' for run attempt $GITHUB_RUN_ATTEMPT"
    exit 0
  fi
fi
exit "$error_code"
