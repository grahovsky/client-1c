#!/bin/bash

docker build --tag grahovsky/client-1c-x32:latest --build-arg VNC_PORT=9000 $1 -- .
