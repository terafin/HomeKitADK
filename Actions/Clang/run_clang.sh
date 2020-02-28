#!/bin/bash

cd $GITHUB_WORKSPACE

# CLANG_ARGUMENTS="-- -IHAP -IPAL -IExternal/HTTP -IExternal/JSON -IExternal/Base64"
# FILES_MODIFIED="HAP/HAPIPAccessoryProtocol.c HAP/HAPMACAddress.c"

echo "clang_arguments: $CLANG_ARGUMENTS"
echo "files-modified: $FILES_MODIFIED"
echo "files-added: $FILES_ADDED"

read -r -a MODIFIED_FILES <<< "$FILES_MODIFIED"
read -r -a ADDED_FILES <<< "$FILES_ADDED"

clang_arguments=""
for element in "${MODIFIED_FILES[@]}"
do
    clang_arguments+="$element "
done
for element in "${ADDED_FILES[@]}"
do
    clang_arguments+="$element "
done

clang_arguments+=" -export-fixes=fixes.yml"

clang_arguments+=" $CLANG_ARGUMENTS "


echo "clang arguments: $clang_arguments"

clang-tidy $clang_arguments > clang_output.txt

CLANG_OUTPUT=`cat clang_output.txt`
FIXES_OUTPUT=`cat fixes.yml`
rm clang_output.txt
rm fixes.yml

echo "Warnings / Errors output:"
echo $CLANG_OUTPUT

PULL_REQUEST_COMMENT=""
PULL_REQUEST_COMMENT+=$'\n```\n'
PULL_REQUEST_COMMENT+=$'Clang Warnings & Errors:\n'
PULL_REQUEST_COMMENT+="$CLANG_OUTPUT"
PULL_REQUEST_COMMENT+="$FIXES_OUTPUT"
PULL_REQUEST_COMMENTz+=$'\n```\n'

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
