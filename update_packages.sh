GITHUB_USERNAME="CodePrakhar"
GITHUB_TOKEN=$token
REPO_LINK="https://github.com/CodePrakhar/auto-dependency-update"

# Path to the text file
TEXT_FILE=updates.txt
PACKAGE_JSON_FILE=package.json

# Extract owner and repository name from the GitHub repository link
REPO_OWNER=$(echo "$REPO_LINK" | awk -F'/' '{print $(NF-1)}')
REPO_NAME=$(echo "$REPO_LINK" | awk -F'/' '{print $NF}' | sed 's/.git$//')
echo "$REPO_OWNER"
echo "$REPO_NAME"

# Loop through each line in the text file
while IFS= read -r line; do
  # Extract package name and latest version using string manipulation or other methods
  package_name=$(echo "$line" | awk -F '[... ]' '{print $4}')
  latest_version=$(echo "$line" | awk '{print $(NF-1)}')
  echo "$package_name"
  echo "$latest_version"

  # Prepare the JSON payload for updating the package.json
  json_payload=$(jq --arg package "$package_name" --arg version "$latest_version" '.dependencies[$package] = $version' "$PACKAGE_JSON_FILE")
  echo "$json_payload"
  # Encode the JSON payload using base64
  encoded_payload=$(echo "$json_payload" | base64 -w 0)

  # Get the current SHA of the package.json file
  current_sha=$(curl -s -u "$GITHUB_USERNAME:$GITHUB_TOKEN" "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents/$PACKAGE_JSON_FILE" | jq -r '.sha')

curl -L -X PUT -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents/$PACKAGE_JSON_FILE \
  -d '{"message":"Update package.json","content":"'"$encoded_payload"'","sha":"'"$current_sha"'"}'

  # Wait for a few seconds to avoid rate limiting (if necessary)
  sleep 3
done < "$TEXT_FILE"
