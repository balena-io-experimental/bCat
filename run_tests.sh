#!/bin/sh

# install yq 

wget https://github.com/mikefarah/yq/releases/download/v4.25.1/yq_linux_amd64.tar.gz -O - | tar xz && mv yq_linux_amd64 /usr/bin/yq




yq '. *= load("docker-compose.test.yml")' docker-compose.yml > a.yml