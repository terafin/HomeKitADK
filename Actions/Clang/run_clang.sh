#!/bin/bash

cd $GITHUB_WORKSPACE
clang-tidy HAP/*.c  -- -IHAP -IPAL -IExternal/HTTP -IExternal/JSON -IExternal/Base64 > clang_output.txt

CLANG_OUTPUT=`cat clang_output.txt`
echo "Clang output:"
echo $CLANG_OUTPUT

OUTPUT=$'**CLANG WARNINGS**:\n'
OUTPUT+=$'\n```\n'

echo "Event path: $GITHUB_EVENT_PATH"
cat $GITHUB_EVENT_PATH

COMMENTS_URL=$(cat $GITHUB_EVENT_PATH | jq -r .pull_request.comments_url)
  
echo "Comment URL: $COMMENTS_URL"

if [ -n "$COMMENTS_URL" ]; then #check to see if we're a pull request
    PAYLOAD=$(echo '{}' | jq --arg body "$OUTPUT" '.body = $body')
    curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/vnd.github.VERSION.text+json" --data "$PAYLOAD" "$COMMENTS_URL"
fi
