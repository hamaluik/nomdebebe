#!/bin/bash
docker run \
  --detach \
  --name nomdebebe-server \
  --restart=unless-stopped \
  --publish "8080:8080" \
  --mount "source=nomdebebe-server-database,target=/data" \
  --env "ADDR=0.0.0.0:8080" \
  --env "SALT=Kosher" \
  --env "PADDING=12" \
  --env "DBPATH=/data/nomdebebe.db" \
  hamaluik/nomdebebe-server:latest

