#!/bin/bash

set -ex

recordedFile=/usr/src/result.wav

echo "Starting SUT..."

# chmod +x test.sh
# ./test.sh

# result=$?

# echo "SUT exited with code $result"

release_id=$(curl "${BALENA_SUPERVISOR_ADDRESS}/v2/applications/${BALENA_APP_ID}/state?apikey=${BALENA_SUPERVISOR_API_KEY}" \
    | jq -r '.local[].services[].releaseId')

echo ${release_id}

#  Updating release tag
curl -X POST --compressed \
"https://api.balena-cloud.com/v6/release_tag" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer ${BALENACLOUD_API_KEY}" \
--data '{
    "release": "${release_id}",
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
