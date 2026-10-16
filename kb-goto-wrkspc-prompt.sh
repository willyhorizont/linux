#!/bin/bash

ACTIVE_WRKSPCS=$(seq 0 $(( $(xdotool get_num_desktops) - 1 )))

TRGT_WRKSPC=$(echo "$ACTIVE_WRKSPCS" | rofi -dmenu -p "Go to Workspace:")

if [ -z "$TRGT_WRKSPC" ]; then
    exit 0
fi

if echo "$TRGT_WRKSPC" | grep -qE '^[0-9]+$'; then
    tot_wrkspc=$(xdotool get_num_desktops)
    if [ "$TRGT_WRKSPC" -ge "$tot_wrkspc" ]; then
        tot_wrkspc_nu=$((TRGT_WRKSPC + 1))
        xdotool set_num_desktops $tot_wrkspc_nu
    fi
    xdotool set_desktop "$TRGT_WRKSPC"
else
    notify-send "kb-goto-wrkspc-prompt.sh" "Error: Invalid input!"
fi
