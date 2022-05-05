#!/bin/bash

recordedFile=/usr/src/result.wav

echo "Starting SUT..."

# chmod +x test.sh 
# ./test.sh

# result=$?

# echo "SUT exited with code $result"

releaseID=$(curl --silent "${BALENA_SUPERVISOR_ADDRESS}/v2/applications/state?apikey=${BALENA_SUPERVISOR_API_KEY}" | jq .[\"bcat-proto\"][\"services\"][\"sut\"][\"releaseId\"])

echo ${releaseID}

#  Updating release tag
curl -X POST --silent --compressed \
"https://api.balena-cloud.com/v6/release_tag" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer ${BALENACLOUD_API_KEY}" \
--data '{
    "release": "${releaseID}",
    "tag_key": "test_result",
    "value": "${result}"
}'

echo "Updated release tag with exit code $result"

# Upload files to temporary storage 

if test -f "${recordedFile}"; then
    echo "Uploading ${recordedFile} exists."
    curl -T ${recordedFile} temp.sh
fi

exit $result
