#!/bin/sh
echo '"ipfs":{'
echo '    "version":"'$(ipfs --version | awk '{ print $3 }')'",'

id=$(ipfs id | jq '.ID') 2>/dev/null
if [ -z "$id" ]; then
    id='""'
fi

echo '    "ID":'${id}

echo "},"