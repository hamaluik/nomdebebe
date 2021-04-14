#!/bin/bash
set -e
source ./version.env
docker tag hamaluik/nomdebebe-server:${CONTAINER_VERSION} hamaluik/nomdebebe-server:latest
docker push hamaluik/nomdebebe-server:${CONTAINER_VERSION}
docker push hamaluik/nomdebebe-server:latest

