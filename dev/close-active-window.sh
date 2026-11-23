#!/bin/sh

if ! command -v xdotool >/dev/null 2>&1 || ! command -v xprop >/dev/null 2>&1; then
    notify-send "close-active-window.sh" "Error: missing dependencies 'xdotool xprop'..."
    exit 1
fi

CUR_ACTV_WIN_ID=$(xdotool getactivewindow 2>/dev/null)
CUR_ACTV_WIN_ID_HEX=$(printf "0x%08x" "$CUR_ACTV_WIN_ID" 2>/dev/null)
WM_CLASS=$(xprop -id "$CUR_ACTV_WIN_ID_HEX" WM_CLASS 2>/dev/null | awk -F'"' '{print $2"."$4}')
WM_NAME=$(xdotool getwindowname "$CUR_ACTV_WIN_ID_HEX" 2>/dev/null)
if [ "$WM_CLASS" = "." ] || [ -z "$WM_CLASS" ]; then
    WM_CLASS="N/A"
fi
if [ "$WM_CLASS" = "N/A" ] || [ -z "$WM_NAME" ]; then
    WIN_NM="$WM_CLASS"
elif [ ${#WM_NAME} -gt 43 ]; then
    WIN_NM="$WM_CLASS ${WM_NAME:0:20}...${WM_NAME: -20}"
else
    WIN_NM="$WM_CLASS $WM_NAME"
fi
if [ "$WIN_NM" = "N/A" ]; then
    WIN_NM="Current Window"
else
    WIN_NM="[${WIN_NM}]"
fi

$HOME/willyhorizont.github.io/linux/confirm-cmd.sh --confirm --msg "Confirm Close ${WIN_NM}" || exit 1

if [ -n "$CUR_ACTV_WIN_ID_HEX" ]; then
    xdotool windowclose "$CUR_ACTV_WIN_ID_HEX"
fi
