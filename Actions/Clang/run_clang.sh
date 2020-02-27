#!/bin/bash

cd $GITHUB_WORKSPACE
clang-tidy HAP/*.c  -- -IHAP -IPAL -IExternal/HTTP -IExternal/JSON -IExternal/Base64 > clang_output.txt

CLANG_OUTPUT=`cat clang_output.txt`
echo "Clang output:"
echo $CLANG_OUTPUT

echo "clang_arguments: $CLANG_ARGUMENTS"
echo "files-modified: $FILES_MODIFIED"
echo "files-added: $FILES_ADDED"

OUTPUT=$'**CLANG WARNINGS**:\n'
OUTPUT+=$'\n```\n'

echo "Event path: $GITHUB_EVENT_PATH"
cat $GITHUB_EVENT_PATH

COMMENTS_URL=$(cat $GITHUB_EVENT_PATH | jq -r .pull_request.comments_url)
  
echo "Comment URL: $COMMENTS_URL"

echo ::set-output name=time::$time


if [ ! -z "$COMMENTS_URL" -a "$str"!="" ]; then
    PAYLOAD=$(echo '{}' | jq --arg body "$OUTPUT" '.body = $body')
    curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/vnd.github.VERSION.text+json" --data "$PAYLOAD" "$COMMENTS_URL"
fi
