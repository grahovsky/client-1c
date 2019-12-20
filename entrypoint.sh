#!/bin/sh
set -e

/usr/bin/x11vnc -rfbport 5920 -display :99 -forever -bg -o /tmp/x11vnc.log -xkb -noxrecord -noxfixes -noxdamage -nomodtweak &

#exec xvfb-run -n 99 -s '-screen 0 1680x1050x24 -shmem' "$@"
( sleep 5 ; xvfb-run sh -c "$@" ) &

exec /usr/bin/Xvfb :99 -screen 0 1680x1050x24



