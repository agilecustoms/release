#!/usr/bin/env bash
# Commit release changes, (re)create tags and push them atomically along with the branch
# Inputs (env): CHANGELOG_FILE, GIT_TAG, GIT_TAGS, VERSION, PRERELEASE, CHANNEL, SERVICE, GH_TOKEN (optional)
set -eo pipefail

branch="$GITHUB_REF_NAME"

# fix any permission issues from earlier steps (npm version can create files with root permissions)
sudo chown -R "$(id -un):$(id -gn)" .

# stage files that might be modified/deleted by previous steps (ignore new files)
git add -u
# one legitime new file is CHANGELOG.md, which is created by release-gen step
[ -f "$CHANGELOG_FILE" ] && git add "$CHANGELOG_FILE"
if ! git diff --cached --quiet; then
  git status --porcelain
  git config --global user.name "github-actions[bot]"
  git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"
  git commit -m "Release version $GIT_TAG [skip ci]"
else
  echo "No changes to commit."
fi

for tag in $GIT_TAGS; do
  git tag -d "$tag" >/dev/null 2>&1 || true
  git tag "$tag"
done

# turn "v1.2.3 v1.2 v1 channel" into "+refs/tags/v1.2.3 +refs/tags/v1.2 +refs/tags/v1 +refs/tags/channel"
# leading '+' forces update of individual ref - needed for floating tags (v1.2, v1, channel) that move on each release
refs=$(echo "$GIT_TAGS" | sed 's/[^ ][^ ]*/+refs\/tags\/&/g')

if [ -z "$VERSION" ] && [ "$PRERELEASE" = "true" ]; then
  git notes --ref semantic-release add -f -m "{\"channels\":[\"$CHANNEL\"]}"
  refs="$refs +refs/notes/semantic-release"
fi

# To run 'git push' you need write permission
# Option 1. job permissions: contents: write (not good for protected branches though)
#  (checkout@v <  6) .git/config is pre-configured with a ${{ github.token }} see misc/.git-config for example
#  (checkout@v >= 6) credentials in a separate file under $RUNNER_TEMP
# Option 2. use an explicit PAT passed as env variable 'GH_TOKEN'
#  => need to apply it to make 'git push' work, but first need to undo checkout@v5/6 configs as they might "win"
# Note: release-gen action (semantic-release under the hood) also calls some git commands,
#  So this Git authorization patch must be either AFTER release-gen step, or retest release-gen if place BEFORE it
if [ -n "${GH_TOKEN:-}" ]; then
  # checkout@v6: remove includeIf sections (credentials stored in $RUNNER_TEMP file)
  git config --local --remove-section "includeIf.gitdir:/home/runner/work/$SERVICE/$SERVICE/.git" 2>/dev/null || true
  git config --local --remove-section "includeIf.gitdir:/home/runner/work/$SERVICE/$SERVICE/.git/worktrees/*" 2>/dev/null || true
  git config --local --remove-section includeIf.gitdir:/github/workspace/.git 2>/dev/null || true
  git config --local --remove-section "includeIf.gitdir:/github/workspace/.git/worktrees/*" 2>/dev/null || true
  # checkout@v5: remove the injected auth header from .git/config
  git config --local --unset-all http.https://github.com/.extraheader 2>/dev/null || true
  # set the remote URL to use PAT token for authentication
  git remote set-url origin "https://x-access-token:${GH_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
fi

# push changes along with tags atomically
# branch is NOT force-pushed: if someone pushed to the branch while release was running, push fails (and no tags pushed)
# instead of silently overwriting their commits. Tags and notes are forced individually via '+' prefix (see above)
# shellcheck disable=SC2086 # $refs is a space-separated list of refspecs
if ! git push --atomic origin "$branch" $refs; then
  # git's own hint ("use 'git pull' before pushing again") is misleading in CI, so explain the common case
  if git fetch -q origin "$branch" 2>/dev/null && [ -n "$(git rev-list HEAD..FETCH_HEAD)" ]; then
    echo "::error title=Release aborted: '$branch' changed during release::Commits were pushed to '$branch' while this release was running, so nothing was pushed (no release commit, no tags). The workflow run for the newer commit should release everything together. If there is no such run (e.g. [skip ci]) or it fails - re-run that one or push again, re-running this run would fail the same way"
    echo "Commits pushed to '$branch' during release:"
    git log --format='  %h %s (%an, %cd)' --date=format:'%H:%M:%S' HEAD..FETCH_HEAD
  else
    echo "::error title=Release aborted: git push failed::Atomic push of '$branch' and tags ($refs) was rejected, nothing was pushed. See git output above"
  fi
  exit 1
fi
