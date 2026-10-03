#!/bin/bash

CURRENT_SCRIPT=$(basename "$0")

TOTAL_PROCS=$(pgrep -f "$CURRENT_SCRIPT" | grep -v "$$" | grep -v "$PPID" | wc -l)

if [ "$TOTAL_PROCS" -gt 0 ]; then
    echo "$CURRENT_SCRIPT already running!"
    exit 1
fi

IDLE_TIME_SEC=10
IDLE_TIME_MS=$((IDLE_TIME_SEC * 1000))
TERMINAL_PID=""
IS_IDLE=false
PENGUINS_ALIVE=false

while true; do
    cur_actv_win_id=$(xdotool getactivewindow 2>/dev/null)
    CURRENT_IDLE=$(xprintidle)
    IS_MAXIMIZED=false
    if [ -n "$cur_actv_win_id" ]; then
        wm_state=$(xprop -id "$cur_actv_win_id" _NET_WM_STATE 2>/dev/null)
        if echo "$wm_state" | grep -qE "MAXIMIZED_HORZ|MAXIMIZED_VERT" && ! echo "$wm_state" | grep -q "HIDDEN"; then
            IS_MAXIMIZED=true
        fi
    fi

    XTERM_ALIVE=false
    if [ -n "$TERMINAL_PID" ] && kill -0 "$TERMINAL_PID" 2>/dev/null; then
        XTERM_ALIVE=true
    fi

    if [ "$IS_MAXIMIZED" = true ] && [ "$CURRENT_IDLE" -lt "$IDLE_TIME_MS" ]; then
        if [ "$PENGUINS_ALIVE" = true ] || pidof xpenguins > /dev/null; then
            echo "User activity detected. Killing xpenguins..."
            pkill -x xpenguins 2>/dev/null
            PENGUINS_ALIVE=false
        fi
        
        if [ "$XTERM_ALIVE" = true ]; then
            kill "$TERMINAL_PID" 2>/dev/null
            IS_IDLE=false
        fi
    else
        if [ "$PENGUINS_ALIVE" = false ] && ! pidof xpenguins > /dev/null; then
            echo "Idle detected. Unleashing xpenguins..."
            xpenguins --nomenu --no-blood --no-angels --nodoublebuffer --ignorepopups --rectwin --delay 120 --penguins 8 --lift 56 &
            PENGUINS_ALIVE=true
        fi

        if [ "$CURRENT_IDLE" -ge "$IDLE_TIME_MS" ] && [ "$XTERM_ALIVE" = false ]; then
            TOTAL_XTERM=$(pgrep -x "xterm" | wc -l)
            if [ "$TOTAL_XTERM" -eq 0 ] && ! pgrep -x "lxterminal" >/dev/null && ! pgrep -x "st" >/dev/null; then
                xterm -geometry 88x25 -bg black -fg white -fa Monospace -fs 8 -bc -uc -hold -e fastfetch &
                # CH=$((RANDOM % 2))
                # if [ "$CH" -eq 0 ]; then
                #     xterm -geometry 88x25 -bg black -fg white -fa Monospace -fs 8 -bc -uc -hold -e fastfetch &
                # else
                #     xterm -geometry 88x25 -bg black -fg white -fa Monospace -fs 8 -bc -uc -e cmatrix -s -u 10 -a &
                # fi
                TERMINAL_PID=$!
                IS_IDLE=true
            fi
        fi
    fi

    if [ "$XTERM_ALIVE" = true ] && [ "$CURRENT_IDLE" -lt "$IDLE_TIME_MS" ]; then
        echo "User activity detected. Killing xterm..."
        kill "$TERMINAL_PID" 2>/dev/null
        IS_IDLE=false
    fi

    sleep 1
done
