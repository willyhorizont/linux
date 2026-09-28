#!/bin/bash

if ! command -v wmctrl &> /dev/null; then
    sudo apt install -y wmctrl
fi

XPENGUINS_ACTIVE=false

while true; do
    HAS_ACTIVE_MAXIMIZED=false

    for win_id in $(wmctrl -l | awk '{print $1}'); do
        wm_state=$(xprop -id "$win_id" _NET_WM_STATE 2>/dev/null)

        if echo "$wm_state" | grep -qE "MAXIMIZED_HORZ|MAXIMIZED_VERT"; then
            if ! echo "$wm_state" | grep -q "HIDDEN"; then
                HAS_ACTIVE_MAXIMIZED=true
                break
            fi
        fi
    done

    if [ "$HAS_ACTIVE_MAXIMIZED" = true ]; then
        if [ "$XPENGUINS_ACTIVE" = true ]; then
            echo "Found Maximized Window! Killing xpenguins..."
            pkill -x xpenguins 2>/dev/null
            XPENGUINS_ACTIVE=false
        fi
    else
        if [ "$XPENGUINS_ACTIVE" = false ]; then
            echo "Maximized Window Not Found. Unleashing xpenguins..."
            xpenguins --nomenu --hidemenu --no-blood --no-angels --nodoublebuffer --penguins 8 --lift 56 &
            XPENGUINS_ACTIVE=true
        fi
    fi

    sleep 0.5
done
