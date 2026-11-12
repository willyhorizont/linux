#!/bin/bash

trap 'echo "Exit signal received"; exit 0' SIGTERM SIGINT
TOT_PROC=$(pgrep -f "$0" | grep -v "$$" | grep -v "$PPID" | wc -l)
if [ "$TOT_PROC" -gt 0 ]; then
    echo "$0 already running!"
    exit 1
fi

CFG="$HOME/willyhorizont.github.io/.config/dmn-screensavr.conf"
CFG_DIR=$(dirname "$CFG")

DFLT_LOCKER="xtrlock"
DFLT_IDLE_SEC=120
DFLT_SHW_TUX="true"
DFLT_SHW_WIN="true"

FLAG_LOCKER=""
FLAG_IDLE=""
FLAG_TUX=""
FLAG_WIN=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        --locker)
            if [ -n "$2" ]; then
                FLAG_LOCKER="$2"
                shift 2
            else
                echo "Error: Missing value for --locker!"
                exit 1
            fi
            ;;
        --idle-sec)
            if [ -n "$2" ] && echo "$2" | grep -qE '^[0-9]+$'; then
                FLAG_IDLE="$2"
                shift 2
            else
                echo "Error: Invalid --idle-sec value!"
                exit 1
            fi
            ;;
        --shw-tux)
            if [ -n "$2" ] && echo "$2" | grep -qE -i '^(true|false)$'; then
                FLAG_TUX=$(echo "$2" | tr '[:upper:]' '[:lower:]')
                shift 2
            else
                echo "Error: Invalid --shw-tux value!"
                exit 1
            fi
            ;;
        --shw-win)
            if [ -n "$2" ] && echo "$2" | grep -qE -i '^(true|false)$'; then
                FLAG_WIN=$(echo "$2" | tr '[:upper:]' '[:lower:]')
                shift 2
            else
                echo "Error: Invalid --shw-win value!"
                exit 1
            fi
            ;;
        *)
            echo "Usage: dmn-screensavr.sh [--locker <command>] [--idle-sec <seconds>] [--shw-tux <true|false>] [--shw-win <true|false>]"
            exit 1
            ;;
    esac
done

mkdir -p "$CFG_DIR"

if [ ! -f "$CFG" ]; then
    W_LOCKER=${FLAG_LOCKER:-$DFLT_LOCKER}
    W_IDLE=${FLAG_IDLE:-$DFLT_IDLE_SEC}
    W_TUX=${FLAG_TUX:-$DFLT_SHW_TUX}
    W_WIN=${FLAG_WIN:-$DFLT_SHW_WIN}

    if [[ "$W_TUX" == "true" ]]; then W_TUX_CAP="True"; else W_TUX_CAP="False"; fi
    if [[ "$W_WIN" == "true" ]]; then W_WIN_CAP="True"; else W_WIN_CAP="False"; fi

    cat << EOF > "$CFG"
locker_command = $W_LOCKER
idle_time_in_sec = $W_IDLE
show_tux = $W_TUX_CAP
show_window = $W_WIN_CAP
EOF
fi

CFG_LOCKER=$(grep -E '^locker_command[[:space:]]*=' "$CFG" | sed 's/[[:space:]]//g' | cut -d= -f2)
CFG_IDLE=$(grep -E '^idle_time_in_sec[[:space:]]*=' "$CFG" | sed 's/[[:space:]]//g' | cut -d= -f2)
CFG_TUX=$(grep -E '^show_tux[[:space:]]*=' "$CFG" | sed 's/[[:space:]]//g' | cut -d= -f2 | tr '[:upper:]' '[:lower:]')
CFG_WIN=$(grep -E '^show_window[[:space:]]*=' "$CFG" | sed 's/[[:space:]]//g' | cut -d= -f2 | tr '[:upper:]' '[:lower:]')

LOCKER_CMD=${FLAG_LOCKER:-${CFG_LOCKER:-$DFLT_LOCKER}}
IDLE_TM_SEC=${FLAG_IDLE:-${CFG_IDLE:-$DFLT_IDLE_SEC}}
SHW_TUX=${FLAG_TUX:-${CFG_TUX:-$DFLT_SHW_TUX}}
SHW_WIN=${FLAG_WIN:-${CFG_WIN:-$DFLT_SHW_WIN}}

IDLE_TM_MS=$((IDLE_TM_SEC * 1000))

if ! command -v xprintidle >/dev/null 2>&1 || ! command -v wmctrl >/dev/null 2>&1 || ! command -v xdotool >/dev/null 2>&1; then
    echo "Error: missing dependencies 'xprintidle wmctrl xdotool'..."
    exit 1
fi

if [[ "$SHW_WIN" == "true" ]]; then
    echo "Opening welcome-window..."
    xterm -bc -uc -u8 -fa Monospace -fs 8 -geometry 88x28 -name "welcome-window" -hold -e fastfetch &
    while true; do
        if [ -n "$("$HOME/willyhorizont.github.io/linux/wmctrl-lxcapg.sh" | awk '$7 == "welcome-window.XTerm" && $9 == "fastfetch" {print $0}' 2>/dev/null)" ]; then
            break
        fi
        sleep 0.2
    done
fi

echo "=================================="
echo " Locker Command    : $LOCKER_CMD"
echo " Idle Timeout      : $IDLE_TM_SEC sec"
echo " Show Tux          : $SHW_TUX"
echo " Show Window       : $SHW_WIN"
echo "=================================="

while true; do
    CUR_IDLE_MS=$(xprintidle 2>/dev/null)
    CUR_ACTV_WIN_ID=$(xdotool getactivewindow 2>/dev/null)
    IS_CUR_ACTV_WIN_MAXED=false
    if [ -n "$CUR_ACTV_WIN_ID" ]; then
        CUR_ACTV_WIN_STATE=$(xprop -id "$CUR_ACTV_WIN_ID" _NET_WM_STATE 2>/dev/null)
        if echo "$CUR_ACTV_WIN_STATE" | grep -qE "MAXIMIZED_HORZ|MAXIMIZED_VERT" && ! echo "$CUR_ACTV_WIN_STATE" | grep -q "HIDDEN"; then
            IS_CUR_ACTV_WIN_MAXED=true
        fi
    fi
    if [ -n "$("$HOME/willyhorizont.github.io/linux/wmctrl-lxcapg.sh" | awk '$7 == "idle-window.XTerm" && $9 == "fastfetch" {print $0}' 2>/dev/null)" ]; then IDLE_WIN_ALIVE=true; else IDLE_WIN_ALIVE=false; fi
    if pgrep -x "xpenguins" >/dev/null; then TUX_ALIVE=true; else TUX_ALIVE=false; fi
    if [ "$CUR_IDLE_MS" -ge "$IDLE_TM_MS" ]; then IS_IDLE=true; else IS_IDLE=false; fi
    if pgrep -x "$LOCKER_CMD" >/dev/null; then IS_LOCKED=true; else IS_LOCKED=false; fi
    if true \
    && [[ "$SHW_WIN" == "true" ]] \
    && [[ "$IDLE_WIN_ALIVE" == false ]] \
    && [[ "$IS_IDLE" == true ]] \
    && true; then
        IS_ACTION_OPEN_IDLE_WINDOW=true
    else
        IS_ACTION_OPEN_IDLE_WINDOW=false
    fi
    if true \
    && [[ "$SHW_WIN" == "true" ]] \
    && [[ "$IDLE_WIN_ALIVE" == true ]] \
    && [[ "$CUR_IDLE_MS" -lt 1000 ]] \
    && [[ "$IS_LOCKED" == false ]] \
    && true; then
        IS_ACTION_CLOSE_IDLE_WINDOW=true
    else
        IS_ACTION_CLOSE_IDLE_WINDOW=false
    fi
    if true \
    && [[ "$SHW_TUX" == "true" ]] \
    && [[ "$TUX_ALIVE" == false ]] \
    && [[ "$IS_CUR_ACTV_WIN_MAXED" == false || "$IS_IDLE" == true || "$IS_LOCKED" == true ]] \
    && true; then
        IS_ACTION_DEPLOY_TUX=true
    else
        IS_ACTION_DEPLOY_TUX=false
    fi
    if true \
    && [[ "$SHW_TUX" == "true" ]] \
    && [[ "$TUX_ALIVE" == true ]] \
    && [[ "$IS_CUR_ACTV_WIN_MAXED" == true && "$IS_IDLE" == false && "$IS_LOCKED" == false ]] \
    && true; then
        IS_ACTION_KILL_TUX=true
    else
        IS_ACTION_KILL_TUX=false
    fi
    if [[ "$IS_ACTION_OPEN_IDLE_WINDOW" == true ]]; then
        echo "Opening idle-window..."
        xterm -bc -uc -u8 -fa Monospace -fs 8 -geometry 88x28 -name "idle-window" -hold -e fastfetch &
        while true; do
            if [ -n "$("$HOME/willyhorizont.github.io/linux/wmctrl-lxcapg.sh" | awk '$7 == "idle-window.XTerm" && $9 == "fastfetch" {print $0}' 2>/dev/null)" ]; then
                break
            fi
            sleep 0.2
        done
        IDLE_WIN_ALIVE=true
    fi
    if [[ "$IS_ACTION_DEPLOY_TUX" == true ]]; then
        echo "Deploying tux..."
        xpenguins --nomenu --no-blood --no-angels --nodoublebuffer --ignorepopups --rectwin --delay 1000 --penguins 8 --lift 52 &
        TUX_ALIVE=true
    fi
    if [[ "$IS_ACTION_CLOSE_IDLE_WINDOW" == true ]]; then
        echo "Closing idle-window..."
        pkill -9 -f "xterm.*-name idle-window" 2>/dev/null
        IDLE_WIN_ALIVE=false
    fi
    if [[ "$IS_ACTION_KILL_TUX" == true ]]; then
        echo "Killing tux..."
        pkill -9 -x "xpenguins" 2>/dev/null
        TUX_ALIVE=false
    fi
    sleep 1
done
