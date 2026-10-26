#!/bin/bash

SCRIPT_NAME="kb-mov-win-to-wrkspc-prompt.sh"
TRGT_WIN_ID="$1"

if [ -z "$TRGT_WIN_ID" ]; then
    notify-send "$SCRIPT_NAME" "Error: Window not found!"
    exit 1
fi

WIN_NM=$(xdotool getwindowname "$TRGT_WIN_ID" 2>/dev/null | cut -c1-30)

ACTIVE_WRKSPCS=$(seq 1 "$(xdotool get_num_desktops)")

ROFI_INPUT=$(echo "$ACTIVE_WRKSPCS" | rofi -dmenu -p "Move [$WIN_NM] to Workspace")

if [ -z "$ROFI_INPUT" ]; then
    exit 0
fi

if echo "$ROFI_INPUT" | grep -qE '^[0-9]+$'; then
    TRGT_WRKSPC=$(( ROFI_INPUT - 1 ))
else
    TRGT_WRKSPC="$ROFI_INPUT"
fi

if echo "$TRGT_WRKSPC" | grep -qE '^[0-9]+$'; then
    tot_wrkspc=$(xdotool get_num_desktops)
    if [ "$TRGT_WRKSPC" -ge "$tot_wrkspc" ]; then
        tot_wrkspc_nu=$((TRGT_WRKSPC + 1))
        xdotool set_num_desktops $tot_wrkspc_nu
    fi
    xdotool set_desktop_for_window "$TRGT_WIN_ID" "$TRGT_WRKSPC"
    xdotool set_desktop "$TRGT_WRKSPC"
else
    notify-send "$SCRIPT_NAME" "Error: Invalid input!"
fi
