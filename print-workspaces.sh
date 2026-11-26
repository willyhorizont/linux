#!/bin/bash

if ! command -v wmctrl >/dev/null 2>&1 || ! command -v xdotool >/dev/null 2>&1; then
    notify-send "kb-tile-cur-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

xprop -root -notype _NET_NUMBER_OF_DESKTOPS | awk '{print $NF}'
xdotool get_num_desktops
wmctrl -d | grep -c .
