#!/bin/sh
docker rm -f client-1c 2> /dev/null

docker run --name client-1c \
  -it \
  --detach \
  --net my_app_net \
  -e VNC_PORT=5900 \
  -p 5900:5900 \
  grahovsky/client-1c:latest

#--privileged
#--volume client-1c:/home/usr1cv8 \

