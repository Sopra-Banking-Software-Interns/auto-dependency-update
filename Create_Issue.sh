#!/bin/bash

# GitHub repository URL
REPO_URL="https://github.com/Sopra-Banking-Software-Interns/auto-dependency-update"

# GitHub personal access token
GITHUB_TOKEN=$token
# echo $GITHUB_TOKEN
# Issue title and body
ISSUE_TITLE="Available version updates"
ISSUE_BODY=$(cat version_changes.txt)

# Extract the owner and repository name from the URL
REPO_OWNER=$(echo "$REPO_URL" | awk -F/ '{print $(NF-1)}')
REPO_NAME=$(echo "$REPO_URL" | awk -F/ '{print $NF}' | sed 's/.git$//')

# Create the issue using the GitHub API
response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d "{\"title\":\"$ISSUE_TITLE\",\"body\":\"$ISSUE_BODY\"}" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/issues")

# Check if the response is valid JSON
if ! jq -e . >/dev/null 2>&1 <<<"$response"; then
  echo "Failed to create the issue"
  echo "API response:"
  echo "$response"
  exit 1
fi

# Extract the issue number from the response
issue_number=$(echo "$response" | jq -r '.number')

# Check if the issue number is null
if [[ "$issue_number" == "null" ]]; then
  echo "Failed to create the issue"
  echo "API response:"
  echo "$response"
  exit 1
fi

# Display the created issue number
echo "New issue created: #$issue_number"
