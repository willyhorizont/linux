#!/bin/bash

CUR_SCPT=$(basename "$0")

TOT_PROC=$(pgrep -f "$CUR_SCPT" | grep -v "$$" | grep -v "$PPID" | wc -l)

if [ "$TOT_PROC" -gt 0 ]; then
    echo "$CUR_SCPT already running!"
    exit 1
fi

IDLE_TM_SEC=10
IDLE_TM_MS=$((IDLE_TM_SEC * 1000))
LCK_TM_MNT=2

while [ "$#" -gt 0 ]; do
    case "$1" in
        --mnt)
            if [ -n "$2" ] && echo "$2" | grep -qE '^[0-9]+$'; then
                LCK_TM_MNT="$2"
                shift 2
            else
                echo "Error: Invalid --mnt value!"
                exit 1
            fi
            ;;
        --help)
            echo "Usage: $CUR_SCPT [--mnt <minutes>]"
            exit 1
            ;;
        *)
            echo "Usage: $CUR_SCPT [--mnt <minutes>]"
            exit 1
            ;;
    esac
done

LCK_TM_MS=$((LCK_TM_MNT * 60 * 1000))

XTERM_PID=""
IS_IDLE=false
TUX_ALIVE=false

while true; do
    CUR_ACTV_WIN_ID=$(xdotool getactivewindow 2>/dev/null)
    CUR_IDLE_MS=$(xprintidle)
    IS_MAXED=false
    if [ -n "$CUR_ACTV_WIN_ID" ]; then
        wm_state=$(xprop -id "$CUR_ACTV_WIN_ID" _NET_WM_STATE 2>/dev/null)
        if echo "$wm_state" | grep -qE "MAXIMIZED_HORZ|MAXIMIZED_VERT" && ! echo "$wm_state" | grep -q "HIDDEN"; then
            IS_MAXED=true
        fi
    fi

    XTERM_ALIVE=false
    if [ -n "$XTERM_PID" ] && kill -0 "$XTERM_PID" 2>/dev/null; then
        XTERM_ALIVE=true
    fi

    if [ "$IS_MAXED" = true ] && [ "$CUR_IDLE_MS" -lt "$IDLE_TM_MS" ]; then
        if [ "$TUX_ALIVE" = true ] || pidof xpenguins > /dev/null; then
            echo "User activity detected. Killing xpenguins..."
            pkill -x xpenguins 2>/dev/null
            TUX_ALIVE=false
        fi
        
        if [ "$XTERM_ALIVE" = true ]; then
            kill "$XTERM_PID" 2>/dev/null
            IS_IDLE=false
        fi
    else
        if [ "$TUX_ALIVE" = false ] && ! pidof xpenguins > /dev/null; then
            echo "Idle detected. Unleashing xpenguins..."
            xpenguins --nomenu --no-blood --no-angels --nodoublebuffer --ignorepopups --rectwin --delay 120 --penguins 8 --lift 56 &
            TUX_ALIVE=true
        fi

        if [ "$CUR_IDLE_MS" -ge "$IDLE_TM_MS" ] && [ "$XTERM_ALIVE" = false ]; then
            TOT_XTERM=$(pgrep -x "xterm" | wc -l)
            if [ "$TOT_XTERM" -eq 0 ] && ! pgrep -x "lxterminal" >/dev/null && ! pgrep -x "st" >/dev/null; then
                xterm -geometry 88x24 -bg black -fg white -fa Monospace -fs 8 -bc -uc -hold -e fastfetch &
                XTERM_PID=$!
                IS_IDLE=true
            fi
        fi
    fi

    if [ "$XTERM_ALIVE" = true ] && [ "$CUR_IDLE_MS" -lt "$IDLE_TM_MS" ]; then
        echo "User activity detected. Killing xterm..."
        kill "$XTERM_PID" 2>/dev/null
        IS_IDLE=false
    fi

    if [ "$CUR_IDLE_MS" -ge "$LCK_TM_MS" ] && ! pgrep -x "xtrlock" >/dev/null; then
        echo "System idle for $LCK_TM_MNT minutes. Locking screen..."
        xtrlock &
    fi

    sleep 1
done
