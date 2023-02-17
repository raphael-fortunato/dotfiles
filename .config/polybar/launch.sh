#!/bin/bash

# Terminate already running bar instances
killall -q polybar
killall -q picom

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar --list-monitors  | while read -r line ; do    
    # MONITOR=$m polybar --reload bar &
    #| cut -d":" -f1
    monitor=$(echo $line | cut -d":" -f1)
    if [[ $(echo $line | awk '{print $NF}') == "(primary)" ]]; then
        MONITOR=$monitor polybar -q --reload mainbar &
    else 
        MONITOR=$monitor polybar -q --reload bar &
    fi
done

picom --experimental-backends -b
