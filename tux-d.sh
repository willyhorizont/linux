#!/bin/bash

while true; do
    cur_actv_win_id=$(xdotool getactivewindow 2>/dev/null)
    if [ -n "$cur_actv_win_id" ]; then
        wm_state=$(xprop -id "$cur_actv_win_id" _NET_WM_STATE 2>/dev/null)
        if echo "$wm_state" | grep -qE "MAXIMIZED_HORZ|MAXIMIZED_VERT" && ! echo "$wm_state" | grep -q "HIDDEN"; then
            if pidof xpenguins > /dev/null; then
                echo "Found Maximized Window! Killing xpenguins..."
                pkill -x xpenguins 2>/dev/null
            fi
        else
            if ! pidof xpenguins > /dev/null; then
                echo "Maximized Window Not Found. Unleashing xpenguins..."
                xpenguins --nomenu --hidemenu --no-blood --no-angels --nodoublebuffer --penguins 8 --lift 56 &
            fi
        fi
    fi

    sleep 0.5
done
