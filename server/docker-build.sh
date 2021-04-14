#!/bin/bash
set -e
source ./version.env
DOCKER_BUILDKIT=1 docker build -t hamaluik/nomdebebe-server:${CONTAINER_VERSION} .

