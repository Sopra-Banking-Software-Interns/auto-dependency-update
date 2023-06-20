truncate -s 0 version_changes.txt
json=$(cat test.json)
echo "$json" | jq -c 'to_entries[]' | while IFS= read -r element; do
    key=$(echo "$element" | jq -r '.key')
    value=$(echo "$element" | jq -r '.value')
    # echo "Key: $key, Value: $value"
    cur=$(npm show $key version)
    # echo $cur
    if [ "$cur" != "$value" ]; then
        echo "Update available for $key... Latest $cur available">>version_changes.txt
    else
        echo "$key is up to date">>version_changes.txt
    fi
done