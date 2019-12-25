#!/bin/sh
set -e

VNC_PORT=${VNC_PORT:=9000}

/usr/bin/x11vnc -rfbport $VNC_PORT -display :99 -forever -bg -o /tmp/x11vnc.log -xkb -noxrecord -noxfixes -noxdamage -nomodtweak &

#exec xvfb-run -n 99 -s '-screen 0 1680x1050x24 -shmem' "$@"
( sleep 5 ; xvfb-run sh -c "$@" ) &

exec /usr/bin/Xvfb :99 -screen 0 1680x1050x24



