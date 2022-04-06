#!/bin/bash

docker build --tag grahovsky/client-1c:8.3.13.1926 --build-arg VNC_PORT=9000 $1 -- .
