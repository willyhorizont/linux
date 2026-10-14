#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    notify-send "cln-trl-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

cur_wrkspc=$(wmctrl -d | grep '*' | cut -d' ' -f1)
tot_wrkspc=$(wmctrl -d | wc -l)
if [ "$tot_wrkspc" -gt 1 ]; then
    actv_wins_wrkspcs=$(wmctrl -l | awk '{print $2}' | grep -E '^[0-9]+$' | sort -u)
    hi_actv_wrkspc=$(echo "$actv_wins_wrkspcs" | sort -n | tail -n 1)
    [ -z "$hi_actv_wrkspc" ] && hi_actv_wrkspc=0
    if [ "$cur_wrkspc" -gt "$hi_actv_wrkspc" ]; then
        trl_wrkspc=$cur_wrkspc
    else
        trl_wrkspc=$hi_actv_wrkspc
    fi
    for ((i=tot_wrkspc-1; i>trl_wrkspc; i--)); do
        cur_tot_wrkspc=$(xdotool get_num_desktops)
        if [ "$cur_tot_wrkspc" -gt 1 ]; then
            tot_wrkspc_nu=$(( cur_tot_wrkspc - 1 ))
            xdotool set_num_desktops $tot_wrkspc_nu
        fi
    done
fi
