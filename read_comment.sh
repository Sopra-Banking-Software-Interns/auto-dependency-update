#!/bin/bash

TOKEN=$token

echo "Here's the new comment that I found:"

# Extract the username and repository name from the GitHub URL
URL="https://github.com/Sopra-Banking-Software-Interns/auto-dependency-update"
USERNAME=$(echo "$URL" | sed -n 's#https://github.com/\([^/]*\)/\([^/]*\).*#\1#p')
REPO=$(echo "$URL" | sed -n 's#https://github.com/\([^/]*\)/\([^/]*\).*#\2#p')

# GitHub API endpoint
API="https://api.github.com"

# Fetch all comments
comments=$(curl -sSL -H "Authorization: token $TOKEN" "$API/repos/$USERNAME/$REPO/issues/comments?per_page=100")

# Check if comments is empty
if [[ -z "$comments" ]]; then
    echo "No comments found."
    exit 0
fi

# Fetch all issues
issues=$(curl -sSL -H "Authorization: token $TOKEN" "$API/repos/$USERNAME/$REPO/issues?state=all&per_page=100")

# Combine comments and issues
all_data=$(echo "$comments" "$issues" | jq -s 'flatten')

# Find the latest comment
latest_comment=$(echo "$all_data" | jq -r '[.[] | {created_at: .created_at, body: .body}] | sort_by(.created_at) | last | .body')

# Check if latest_comment is empty
if [[ -z "$latest_comment" ]]; then
    echo "No latest comment found."
    exit 0
fi

# Output the comment to a text file
echo "$latest_comment" > update_requirement.txt
echo "Latest comment has been written to update_requirement.txt file."
