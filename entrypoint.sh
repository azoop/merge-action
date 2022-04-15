#!/bin/sh

set -e

[ -z "$GITHUB_TOKEN" ] && \
  echo "Set the GITHUB_TOKEN env variable." && \
  exit 1

[ "$(jq -r ".action" "$GITHUB_EVENT_PATH")" != "created" ] && \
  echo "This is not a new comment event" && \
  exit 78

echo "Checking if contains '/merge' command..."
(jq -r ".comment.body" "$GITHUB_EVENT_PATH" | grep -E "/merge") || exit 78

echo "Checking if a PR command..."
(jq -r ".issue.pull_request.url" "$GITHUB_EVENT_PATH") || exit 78

BASE_BRANCH=$(jq -r ".comment.body" "$GITHUB_EVENT_PATH" | cut -c 8-)

PR_NUMBER=$(jq -r ".issue.number" "$GITHUB_EVENT_PATH")
REPO_FULLNAME=$(jq -r ".repository.full_name" "$GITHUB_EVENT_PATH")
echo "Collecting information about PR #$PR_NUMBER of $REPO_FULLNAME..."

URI=https://api.github.com
API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token $GITHUB_TOKEN"

pr_resp=$(curl -X GET -s -H "${AUTH_HEADER}" -H "${API_HEADER}" "${URI}/repos/$REPO_FULLNAME/pulls/$PR_NUMBER")

HEAD_REPO=$(echo "$pr_resp" | jq -r .head.repo.full_name)
HEAD_BRANCH=$(echo "$pr_resp" | jq -r .head.ref)

git remote set-url origin https://x-access-token:$GITHUB_TOKEN@github.com/$REPO_FULLNAME.git
git config --global --add safe.directory /github/workspace
git config --global user.email "actions@github.com"
git config --global user.name "GitHub Merge Action"

set -o xtrace

git fetch origin $HEAD_BRANCH
git checkout -b $HEAD_BRANCH origin/$HEAD_BRANCH
git fetch origin $BASE_BRANCH
git checkout -b $BASE_BRANCH origin/$BASE_BRANCH

# do the merge
git merge $HEAD_BRANCH --no-edit
git push origin $BASE_BRANCH 
