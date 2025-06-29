#!/bin/bash
# npm install -g semantic-release
semantic-release --dry-run \
 --plugins @semantic-release/commit-analyzer @semantic-release/release-notes-generator