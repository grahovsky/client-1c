#!/bin/sh
docker rm -f client-onec 2> /dev/null

docker run --name client-onec \
  -it \
  --detach \
  --net my_app_net \
  -p 5920:5920 \
  --privileged \
  grahovsky/client-onec:latest
