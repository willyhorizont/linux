#!/bin/bash

CUR_SCPT=$(basename "$0")

TOT_PROC=$(pgrep -f "$CUR_SCPT" | grep -v "$$" | grep -v "$PPID" | wc -l)
if [ "$TOT_PROC" -gt 0 ]; then
    echo "$CUR_SCPT already running!"
    exit 1
fi

CFG="$HOME/willyhorizont.github.io/.config/screenlockerd.conf"
CFG_DIR=$(dirname "$CFG")

DFLT_IDLE_SEC=120
DFLT_LOCK_MNT=5
DFLT_SHW_TUX="true"

FLAG_IDLE=""
FLAG_LOCK=""
FLAG_TUX=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        --idle-sec)
            if [ -n "$2" ] && echo "$2" | grep -qE '^[0-9]+$'; then
                FLAG_IDLE="$2"
                shift 2
            else
                echo "Error: Invalid --idle-sec value!"
                exit 1
            fi
            ;;
        --lock-mnt)
            if [ -n "$2" ] && echo "$2" | grep -qE '^[0-9]+$'; then
                FLAG_LOCK="$2"
                shift 2
            else
                echo "Error: Invalid --lock-mnt value!"
                exit 1
            fi
            ;;
        --show-tux)
            if [ -n "$2" ] && echo "$2" | grep -qE -i '^(true|false)$'; then
                FLAG_TUX=$(echo "$2" | tr '[:upper:]' '[:lower:]')
                shift 2
            else
                echo "Error: Invalid --show-tux value!"
                exit 1
            fi
            ;;
        *)
            echo "Usage: $CUR_SCPT [--idle-sec <seconds>] [--lock-mnt <minutes>] [--show-tux <true|false>]"
            exit 1
            ;;
    esac
done

mkdir -p "$CFG_DIR"

if [ ! -f "$CFG" ]; then
    W_IDLE=${FLAG_IDLE:-$DFLT_IDLE_SEC}
    W_LOCK=${FLAG_LOCK:-$DFLT_LOCK_MNT}
    W_TUX=${FLAG_TUX:-$DFLT_SHW_TUX}
    
    if [ "$W_TUX" = "true" ]; then W_TUX_CAP="True"; else W_TUX_CAP="False"; fi

    cat << EOF > "$CFG"
idle_time_in_sec = $W_IDLE
lock_time_in_minute = $W_LOCK
show_tux = $W_TUX_CAP
EOF
fi

CFG_IDLE=$(grep -E '^idle_time_in_sec[[:space:]]*=' "$CFG" | sed 's/[[:space:]]//g' | cut -d= -f2)
CFG_LOCK=$(grep -E '^lock_time_in_minute[[:space:]]*=' "$CFG" | sed 's/[[:space:]]//g' | cut -d= -f2)
CFG_TUX=$(grep -E '^show_tux[[:space:]]*=' "$CFG" | sed 's/[[:space:]]//g' | cut -d= -f2 | tr '[:upper:]' '[:lower:]')

IDLE_TM_SEC=${FLAG_IDLE:-${CFG_IDLE:-$DFLT_IDLE_SEC}}
LOCK_TM_MNT=${FLAG_LOCK:-${CFG_LOCK:-$DFLT_LOCK_MNT}}
SHW_TUX=${FLAG_TUX:-${CFG_TUX:-$DFLT_SHW_TUX}}

IDLE_TM_MS=$((IDLE_TM_SEC * 1000))
LOCK_TM_MS=$((LOCK_TM_MNT * 60 * 1000))

echo "=== $CUR_SCPT Initialization ==="
echo " Idle Timeout      : $IDLE_TM_SEC sec"
echo " Auto-Lock Timeout : $LOCK_TM_MNT min"
echo " Show Tux          : $SHW_TUX"
echo "=================================="

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
        if [ "$SHW_TUX" = "true" ] && [ "$TUX_ALIVE" = false ] && ! pidof xpenguins > /dev/null; then
            echo "Idle detected. Unleashing xpenguins..."
            xpenguins --nomenu --no-blood --no-angels --nodoublebuffer --ignorepopups --rectwin --delay 1000 --penguins 8 --lift 56 &
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

    if [ "$CUR_IDLE_MS" -ge "$LOCK_TM_MS" ] && ! pgrep -x "xtrlock" >/dev/null; then
        echo "System idle for $LOCK_TM_MNT minutes. Locking screen..."
        xtrlock &
    fi

    sleep 1
done
