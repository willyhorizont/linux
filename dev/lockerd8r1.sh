#!/bin/bash

TOT_PROC=$(pgrep -f "$0" | grep -v "$$" | grep -v "$PPID" | wc -l)
if [ "$TOT_PROC" -gt 0 ]; then
    echo "$0 already running!"
    exit 1
fi

CFG="$HOME/willyhorizont.github.io/.config/lockerd.conf"
CFG_DIR=$(dirname "$CFG")

DFLT_IDLE_SEC=120
DFLT_LOCK_MNT=4
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
            echo "Usage: lockerd.sh [--idle-sec <seconds>] [--lock-mnt <minutes>] [--show-tux <true|false>]"
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

if ! command -v xprintidle >/dev/null 2>&1 || ! command -v wmctrl >/dev/null 2>&1; then
    echo "Installing missing dependencies 'xprintidle wmctrl'..."
    sudo apt update && sudo apt install xprintidle wmctrl -y
fi

pkill -x xtrlock 2>/dev/null

xterm -name "welcome-window" -geometry 88x24 -bg black -fg white -fa Monospace -fs 8 -bc -uc -hold -e fastfetch &
xdotool search --sync --classname "welcome-window" >/dev/null 2>&1

TUX_ALIVE=false
CUR_ACTV_WIN_ID=$(xdotool getactivewindow 2>/dev/null)
IS_CUR_ACTV_WIN_MAXED=false
if [ -n "$CUR_ACTV_WIN_ID" ]; then
    CUR_ACTV_WIN_STATE=$(xprop -id "$CUR_ACTV_WIN_ID" _NET_WM_STATE 2>/dev/null)
    if echo "$CUR_ACTV_WIN_STATE" | grep -qE "MAXIMIZED_HORZ|MAXIMIZED_VERT" && ! echo "$CUR_ACTV_WIN_STATE" | grep -q "HIDDEN"; then
        IS_CUR_ACTV_WIN_MAXED=true
    fi
fi

if [ "$SHW_TUX" = "true" ] && [ "$IS_CUR_ACTV_WIN_MAXED" = false ]; then
    echo "Deploying tux..."
    xpenguins --nomenu --no-blood --no-angels --nodoublebuffer --ignorepopups --rectwin --delay 1000 --penguins 8 --lift 56 &
    TUX_ALIVE=true
fi

echo "=================================="
echo " Idle Timeout      : $IDLE_TM_SEC sec"
echo " Auto-Lock Timeout : $LOCK_TM_MNT mnt"
echo " Show Tux          : $SHW_TUX"
echo "=================================="

while true; do
    TOT_OPEN_WINS=$(wmctrl -l -x 2>/dev/null | awk '{print $3}' | grep -vE "plank\.Plank|tint2\.Tint2|xpenguins\.Xpenguins" | wc -l)
    CUR_IDLE_MS=$(xprintidle 2>/dev/null)
    CUR_ACTV_WIN_ID=$(xdotool getactivewindow 2>/dev/null)
    IS_CUR_ACTV_WIN_MAXED=false
    if [ -n "$CUR_ACTV_WIN_ID" ]; then
        CUR_ACTV_WIN_STATE=$(xprop -id "$CUR_ACTV_WIN_ID" _NET_WM_STATE 2>/dev/null)
        if echo "$CUR_ACTV_WIN_STATE" | grep -qE "MAXIMIZED_HORZ|MAXIMIZED_VERT" && ! echo "$CUR_ACTV_WIN_STATE" | grep -q "HIDDEN"; then
            IS_CUR_ACTV_WIN_MAXED=true
        fi
    fi
    CUR_ACTV_WIN_CLASS=""
    if [ -n "$CUR_ACTV_WIN_ID" ]; then
        CUR_ACTV_WIN_CLASS=$(xdotool getwindowclassname "$CUR_ACTV_WIN_ID" 2>/dev/null)
    fi

    WELCOME_WIN_ALIVE=false
    if xdotool search --classname "welcome-window" >/dev/null 2>&1; then
        WELCOME_WIN_ALIVE=true
    fi

    IDLE_WIN_ALIVE=false
    if xdotool search --classname "idle-window" >/dev/null 2>&1; then
        IDLE_WIN_ALIVE=true
    fi

    if [ "$CUR_IDLE_MS" -lt 1000 ] && ! pgrep -x "xtrlock" >/dev/null; then
        if [ "$TOT_OPEN_WINS" -gt 2 ]; then
            if [ "$IS_CUR_ACTV_WIN_MAXED" = true ]; then
                if [ "$CUR_ACTV_WIN_CLASS" != "welcome-window" ] && [ "$CUR_ACTV_WIN_CLASS" != "idle-window" ]; then
                    if [ "$WELCOME_WIN_ALIVE" = true ]; then
                        echo "Closing welcome-window..."
                        pkill -f "xterm -name welcome-window" 2>/dev/null
                        WELCOME_WIN_ALIVE=false
                    fi
                    if [ "$IDLE_WIN_ALIVE" = true ]; then
                        echo "Closing idle-window..."
                        pkill -f "xterm -name idle-window" 2>/dev/null
                        IDLE_WIN_ALIVE=false
                    fi
                    if [ "$TUX_ALIVE" = true ] || pidof xpenguins > /dev/null; then
                        echo "Killing tux..."
                        pkill -x xpenguins 2>/dev/null
                        TUX_ALIVE=false
                    fi
                fi
            else
                if [ "$WELCOME_WIN_ALIVE" = true ]; then
                    echo "Closing welcome-window..."
                    pkill -f "xterm -name welcome-window" 2>/dev/null
                    WELCOME_WIN_ALIVE=false
                fi
                if [ "$IDLE_WIN_ALIVE" = true ]; then
                    echo "Closing idle-window..."
                    pkill -f "xterm -name idle-window" 2>/dev/null
                    IDLE_WIN_ALIVE=false
                fi
                if [ "$SHW_TUX" = "true" ] && [ "$TUX_ALIVE" = false ] && ! pidof xpenguins > /dev/null; then
                    echo "Deploying tux..."
                    xpenguins --nomenu --no-blood --no-angels --nodoublebuffer --ignorepopups --rectwin --delay 1000 --penguins 8 --lift 56 &
                    TUX_ALIVE=true
                fi
            fi
        else
            if [ "$SHW_TUX" = "true" ] && [ "$TUX_ALIVE" = false ] && ! pidof xpenguins > /dev/null; then
                echo "Deploying tux..."
                xpenguins --nomenu --no-blood --no-angels --nodoublebuffer --ignorepopups --rectwin --delay 1000 --penguins 8 --lift 56 &
                TUX_ALIVE=true
            fi
        fi
    else
        if [ "$CUR_IDLE_MS" -ge "$IDLE_TM_MS" ] && [ "$CUR_IDLE_MS" -lt "$LOCK_TM_MS" ]; then
            if [ "$WELCOME_WIN_ALIVE" = false ] && [ "$IDLE_WIN_ALIVE" = false ]; then
                echo "Opening idle-window..."
                xterm -name "idle-window" -geometry 88x24 -bg black -fg white -fa Monospace -fs 8 -bc -uc -hold -e fastfetch &
            fi

            if [ "$SHW_TUX" = "true" ] && [ "$TUX_ALIVE" = false ] && ! pidof xpenguins > /dev/null; then
                echo "Deploying tux..."
                xpenguins --nomenu --no-blood --no-angels --nodoublebuffer --ignorepopups --rectwin --delay 1000 --penguins 8 --lift 56 &
                TUX_ALIVE=true
            fi
        fi

        if [ "$CUR_IDLE_MS" -ge "$LOCK_TM_MS" ]; then
            if [ "$WELCOME_WIN_ALIVE" = false ] && [ "$IDLE_WIN_ALIVE" = false ]; then
                echo "Opening idle-window..."
                xterm -name "idle-window" -geometry 88x24 -bg black -fg white -fa Monospace -fs 8 -bc -uc -hold -e fastfetch &
                xdotool search --sync --classname "idle-window" >/dev/null 2>&1
            fi

            if [ "$SHW_TUX" = "true" ] && [ "$TUX_ALIVE" = false ] && ! pidof xpenguins > /dev/null; then
                echo "Deploying tux..."
                xpenguins --nomenu --no-blood --no-angels --nodoublebuffer --ignorepopups --rectwin --delay 1000 --penguins 8 --lift 56 &
                TUX_ALIVE=true
            fi

            if ! pgrep -x "xtrlock" >/dev/null; then
                echo "Locking..."
                xtrlock &
            fi
        fi
    fi

    sleep 1
done
