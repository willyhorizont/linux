#!/bin/bash

trap 'echo "Exit signal received"; exit 0' SIGTERM SIGINT
TOT_PROC=$(pgrep -f "$0" | grep -v "$$" | grep -v "$PPID" | wc -l)
if [ "$TOT_PROC" -gt 0 ]; then
    echo "$0 already running!"
    exit 1
fi

CFG="$HOME/willyhorizont.github.io/.config/dmn-wrkspc-mgr.conf"
CFG_DIR=$(dirname "$CFG")
CLN_SCRIPT="$HOME/willyhorizont.github.io/linux/kb-cln-wrkspc.sh"

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
            echo "Usage: dmn-wrkspc-mgr.sh [--intrvl-sec <seconds>]"
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

if [ ! -f "$CLN_SCRIPT" ]; then
    echo "Error: $CLN_SCRIPT not found!"
    exit 1
fi

echo "=================================="
echo " Interval Auto Clean Workspace : $INTRVL_TM_SEC sec"
echo "=================================="

while true; do
    bash -c "$CLN_SCRIPT"
    sleep "$INTRVL_TM_SEC"
done
