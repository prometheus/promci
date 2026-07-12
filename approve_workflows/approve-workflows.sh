#!/usr/bin/env bash

set -euo pipefail

if [[ -z "${GITHUB_REPOSITORY:-}" || -z "${PR_NUMBER:-}" || -z "${SENDER:-}" ]]; then
    echo "GITHUB_REPOSITORY, PR_NUMBER, and SENDER must be set"
    exit 1
fi

if ! ROLE=$(
    gh api \
        "repos/${GITHUB_REPOSITORY}/collaborators/${SENDER}/permission" \
        --jq '.role_name' \
        2>/dev/null
); then
    echo "Unable to determine repository access for ${SENDER}"
    exit 1
fi

case "${ROLE}" in
    triage | write | maintain | admin)
        ;;
    *)
        echo "${SENDER} does not have triage or higher access to ${GITHUB_REPOSITORY}"
        gh pr comment "${PR_NUMBER}" \
            --repo "${GITHUB_REPOSITORY}" \
            --body "Workflow approval requires **triage access or higher** on this repository."
        exit 0
        ;;
esac

if ! HEAD_SHA=$(
    gh pr view "${PR_NUMBER}" \
        --repo "${GITHUB_REPOSITORY}" \
        --json headRefOid \
        --jq '.headRefOid // empty'
); then
    echo "Unable to determine the head commit for pull request ${PR_NUMBER}"
    exit 1
fi

if [[ -z "${HEAD_SHA}" ]]; then
    echo "Pull request ${PR_NUMBER} does not have a head commit"
    exit 1
fi

echo "Finding pull request workflows awaiting approval for ${HEAD_SHA}"

mapfile -t WAITING_RUNS < <(
    gh run list \
        --repo "${GITHUB_REPOSITORY}" \
        --commit "${HEAD_SHA}" \
        --limit 100 \
        --json databaseId,conclusion,event \
        --jq '.[] | select(.conclusion == "action_required" and .event == "pull_request") | .databaseId'
)

if [[ ${#WAITING_RUNS[@]} -eq 0 ]]; then
    echo "No workflows are awaiting approval"
    exit 0
fi

for RUN_ID in "${WAITING_RUNS[@]}"; do
    echo "Approving workflow run ${RUN_ID}"
    gh api \
        --method POST \
        "repos/${GITHUB_REPOSITORY}/actions/runs/${RUN_ID}/approve" \
        --silent
done
