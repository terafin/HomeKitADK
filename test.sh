#!/bin/bash

apt-get -fy install clang-format clang-tidy
clang-tidy HAP/*.c  -- -IHAP -IPAL -IExternal/HTTP -IExternal/JSON -IExternal/Base64 > clang_output.txt

CLANG_OUTPUT=`cat clang_output.txt`
COMMENTS_URL=$(cat $GITHUB_EVENT_PATH | jq -r .pull_request.comments_url)
  
echo $COMMENTS_URL
echo "Clang errors:"
echo $CLANG_OUTPUT

OUTPUT=$'**CLANG WARNINGS**:\n'
OUTPUT+=$'\n```\n'

PAYLOAD=$(echo '{}' | jq --arg body "$OUTPUT" '.body = $body')

curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/vnd.github.VERSION.text+json" --data "$PAYLOAD" "$COMMENTS_URL"
