#!/bin/sh
set -e

VNC_PORT=${VNC_PORT:=9000}
RESOLUTION=${RESOLUTION:=1920x1080x24}

kill_xvfb () {
    
    local xvfb_pids=`ps aux | grep tmp/xvfb-run | grep -v grep | awk '{print $2}'`
    if [ "$xvfb_pids" != "" ]; then
        echo "Killing the following xvfb processes: $xvfb_pids"
        sudo kill $xvfb_pids
    else
        echo "No xvfb processes to kill"
    fi

}

startsession() {
    
    # initialize config
    if [ -z "$(ls -A /home/usr1cv8/.1C/1cestart/1cestart.cfg 2>/dev/null)" ]; then

        # start session        
        xvfb-run sh -c $1 &
        XVFB_ID=$!
        sleep 10;
        
        # stop session
        kill $XVFB_ID
        ps ax | grep -E '1cv8s' | grep -Ev 'grep|xvfb|entrypoint' | awk '{print $1}' | xargs kill 2>/dev/null

        # change config
        cp /distrib/config/1cestart.cfg /home/usr1cv8/.1C/1cestart/1cestart.cfg

    fi

    xvfb-run sh -c $1

}


#( sleep 10 ; kill_xvfb ; startsession $@) &
#( sleep 10 ; kill_xvfb ) &

/usr/bin/x11vnc -rfbport $VNC_PORT -display :99 -forever -bg -o /tmp/x11vnc.log -xkb -noxrecord -noxfixes -noxdamage -nomodtweak &

#exec xvfb-run -n 99 -s '-screen 0 $RESOLUTION -shmem' 1cv8s 
exec /usr/bin/Xvfb :99 -screen 0 $RESOLUTION -nolisten tcp



