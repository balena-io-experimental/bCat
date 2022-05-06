#!/bin/bash

set -e

recordedFile=/data/result.png

echo "Starting SUT..."
cp testImage.png /data

npm start

result=$?

echo "SUT exited with code $result"

release_id=$(curl --silent "${BALENA_SUPERVISOR_ADDRESS}/v2/applications/state?apikey=${BALENA_SUPERVISOR_API_KEY}" \
    | jq -r '.[].services.sut.releaseId')

echo ${release_id}

#  Updating release tag
curl --silent -X POST --compressed \
"https://api.balena-cloud.com/v6/release_tag" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer ${BALENACLOUD_API_KEY}" \
--data '{
    "release": "'${release_id}'",
    "tag_key": "test_result",
    "value": "'${result}'"
}'

echo "Updated release tag with exit code $result"

# Upload files to temporary storage

if test -f "${recordedFile}"; then
    echo "Uploading ${recordedFile} exists."
    curl -T ${recordedFile} temp.sh
fi

exit $result
