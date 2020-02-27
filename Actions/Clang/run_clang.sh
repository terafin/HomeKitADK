#!/bin/bash

cd $GITHUB_WORKSPACE



clang-tidy HAP/*.c PAL/*.c PAL/Mock/*.c External/HTTP/*.c External/JSON/*.c External/Base64/*.c -- -IHAP -IPAL -IExternal/HTTP -IExternal/JSON -IExternal/Base64 > clang_output.txt

CLANG_OUTPUT=`cat clang_output.txt`
echo "Clang output:"
echo $CLANG_OUTPUT

echo "clang_arguments: $CLANG_ARGUMENTS"
echo "files-modified: $FILES_MODIFIED"
echo "files-added: $FILES_ADDED"

PULL_REQUEST_COMMENT=""
PULL_REQUEST_COMMENT+=$'\n```\n'
PULL_REQUEST_COMMENT+=$'Clang output:\n'
PULL_REQUEST_COMMENT+="$CLANG_OUTPUT"
PULL_REQUEST_COMMENT+=$'\n```\n'

echo "Event path: $GITHUB_EVENT_PATH"
cat $GITHUB_EVENT_PATH

PULL_REQUEST_COMMENT_URL=$(cat $GITHUB_EVENT_PATH | jq -r .pull_request.comments_url)
  
echo "Comment URL: $PULL_REQUEST_COMMENT_URL"

echo ::set-output name=clang-result::$CLANG_OUTPUT

if [ ! -z "$PULL_REQUEST_COMMENT_URL" -a "$str"!="" -a "$str"!="null" ]; then
    echo "Posting to comment URL: $PULL_REQUEST_COMMENT_URL"

    REQUEST_DATA=$(echo '{}' | jq --arg body "$PULL_REQUEST_COMMENT" '.body = $body')
    curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/vnd.github.VERSION.text+json" --data "$REQUEST_DATA" "$PULL_REQUEST_COMMENT_URL"
fi
