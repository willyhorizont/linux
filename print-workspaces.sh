#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    notify-send "kb-tile-cur-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

xprop -root -notype _NET_NUMBER_OF_DESKTOPS | awk '{print $NF}'
xdotool get_num_desktops
wmctrl -d | grep -c .
