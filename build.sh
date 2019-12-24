#!/bin/bash

docker build --tag grahovsky/client-1c:latest --build-arg VNC_PORT=9020 $1 -- .
