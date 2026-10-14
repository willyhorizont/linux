#!/bin/bash

trap 'echo "Exit signal received"; exit 0' SIGTERM SIGINT
TOT_PROC=$(pgrep -f "$0" | grep -v "$$" | grep -v "$PPID" | wc -l)
if [ "$TOT_PROC" -gt 0 ]; then
    echo "$0 already running!"
    exit 1
fi

CFG="$HOME/willyhorizont.github.io/.config/dmn-openbox-wrkspc.conf"
CFG_DIR=$(dirname "$CFG")

DFLT_INTRVL_SEC=60

FLAG_INTRVL=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        --intrvl-sec)
            if [ -n "$2" ] && echo "$2" | grep -qE '^[0-9]+$'; then
                FLAG_INTRVL="$2"
                shift 2
            else
                echo "Error: Invalid --intrvl-sec value!"
                exit 1
            fi
            ;;
        *)
            echo "Usage: dmn-openbox-wrkspc.sh [--intrvl-sec <seconds>]"
            exit 1
            ;;
    esac
done

mkdir -p "$CFG_DIR"

if [ ! -f "$CFG" ]; then
    W_INTRVL=${FLAG_INTRVL:-$DFLT_INTRVL_SEC}

    cat << EOF > "$CFG"
interval_in_sec = $W_INTRVL
EOF
fi

CFG_INTRVL=$(grep -E '^interval_in_sec[[:space:]]*=' "$CFG" | sed 's/[[:space:]]//g' | cut -d= -f2)

INTRVL_TM_SEC=${FLAG_INTRVL:-${CFG_INTRVL:-$DFLT_INTRVL_SEC}}

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    echo "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

echo "=================================="
echo " Interval Auto Clean Workspace : $INTRVL_TM_SEC sec"
echo "=================================="

while true; do
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
    sleep $INTRVL_TM_SEC
done
