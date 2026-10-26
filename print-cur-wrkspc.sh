#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    notify-send "kb-tile-cur-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

xprop -root -notype _NET_CURRENT_DESKTOP | awk '{print $NF}'
xdotool get_desktop
wmctrl -d | awk '{if ($2 == "*") print $1}'
