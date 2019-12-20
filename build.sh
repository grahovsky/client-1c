#!/bin/bash

docker build --tag grahovsky/client-onec:latest --build-arg VNC_PORT=9020 $1 -- .
