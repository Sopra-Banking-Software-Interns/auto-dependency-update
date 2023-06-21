#!/bin/bash

TOKEN=$token

# Extract the username and repository name from the GitHub URL
URL="https://github.com/Sopra-Banking-Software-Interns/auto-dependency-update"
USERNAME=$(echo "$URL" | sed -n 's#https://github.com/\([^/]*\)/\([^/]*\).*#\1#p')
REPO=$(echo "$URL" | sed -n 's#https://github.com/\([^/]*\)/\([^/]*\).*#\2#p')

# GitHub API endpoint
API="https://api.github.com"

# Fetch all comments
comments=$(curl -sSL -H "Authorization: token $TOKEN" "$API/repos/$USERNAME/$REPO/issues/comments")

# Find the latest comment
latest_comment=$(echo "$comments" | jq -r 'max_by(.created_at).body')

# Output the comment to a text file
echo "$latest_comment" > update_requirements.txt
