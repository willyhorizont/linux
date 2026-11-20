#!/bin/sh

if ! command -v xdotool >/dev/null 2>&1; then
    notify-send "close-active-window.sh" "Error: missing dependencies 'xdotool'..."
    exit 1
fi

CUR_ACTV_WIN_ID=$(xdotool getactivewindow 2>/dev/null)
CUR_ACTV_WIN_ID_HEX=$(printf "0x%08x" "$CUR_ACTV_WIN_ID" 2>/dev/null)

$HOME/willyhorizont.github.io/linux/confirm-cmd.sh --confirm --msg "Confirm Close This Window" || exit 1

if [ -n "$CUR_ACTV_WIN_ID_HEX" ]; then
    xdotool windowclose "$CUR_ACTV_WIN_ID_HEX"
fi
