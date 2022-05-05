#!/bin/bash

echo "Starting SUT..."

chmod +x test.sh 
./test.sh

result=$?

echo "SUT exited with code $result"

#  Updating release tag

curl -X POST \
"https://api.balena-cloud.com/v6/release_tag" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer ${BALENACLOUD_API_KEY}" \
--data '{
    "release": "956d4112d76d3b1d35d2615249b79259",
    "tag_key": "test_result",
    "value": "$result"
}'

echo "Updated release tag with exit code $result"

# Upload files to temporary storage 
curl -T /usr/src/result.wav temp.sh

exit $result