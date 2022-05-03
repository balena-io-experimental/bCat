#!/bin/sh



yq '. *= load("docker-compose.test.yml")' docker-compose.yml > a.yml