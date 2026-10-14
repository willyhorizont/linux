#!/bin/bash

TRGT_WIN_ID="$1"

if [ -z "$TRGT_WIN_ID" ]; then
    notify-send "openbox-mov-win-to-wrkspc.sh" "Error: Window not found!"
    exit 1
fi

WIN_NM=$(xdotool getwindowname "$TRGT_WIN_ID" 2>/dev/null | cut -c1-30)

clear
echo "========================================"
echo " openbox-mov-win-to-wrkspc.sh "
echo "========================================"
echo "Target Window : [$TRGT_WIN_ID] $WIN_NM"
echo "----------------------------------------"
echo -n "Enter workspace target: "

read -r TRGT_WRKSPC

if echo "$TRGT_WRKSPC" | grep -qE '^[0-9]+$'; then
    tot_wrkspc=$(xdotool get_num_desktops)
    if [ "$TRGT_WRKSPC" -ge "$tot_wrkspc" ]; then
        tot_wrkspc_nu=$((TRGT_WRKSPC + 1))
        xdotool set_num_desktops $tot_wrkspc_nu
    fi
    xdotool set_desktop_for_window "$TRGT_WIN_ID" "$TRGT_WRKSPC"
    xdotool set_desktop "$TRGT_WRKSPC"
else
    notify-send "openbox-mov-win-to-wrkspc.sh" "Error: Invalid input!"
fi
