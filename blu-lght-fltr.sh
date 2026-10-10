#!/bin/bash

CFG="$HOME/willyhorizont.github.io/.config/blu-lght-fltr.conf"
CFG_DIR=$(dirname "$CFG")
OVERRIDE_FILE="/tmp/blu-lght-fltr-override"

if [ ! -f "$CFG" ]; then
    mkdir -p "$CFG_DIR"
    cat << EOF > "$CFG"
auto_toggle_blue_light_filter = False
turn_on_at = 06:00 PM
turn_off_at = 06:00 AM
EOF
fi

V_AUTO=$(grep -E '^auto_toggle_blue_light_filter' "$CFG" | sed 's/[[:space:]]//g' | cut -d= -f2)
V_ON=$(grep -E '^turn_on_at' "$CFG" | cut -d= -f2 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
V_OFF=$(grep -E '^turn_off_at' "$CFG" | cut -d= -f2 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

if [ "$V_AUTO" != "True" ]; then
    exit 0
fi

if [ -f "$OVERRIDE_FILE" ]; then
    exit 0
fi

on_mnt=$(date -d "$V_ON" +"%H*60+%M" | bc)
off_mnt=$(date -d "$V_OFF" +"%H*60+%M" | bc)
cur_mnt=$(date +"%H*60+%M" | bc)

in_range=false

if [ "$on_mnt" -lt "$off_mnt" ]; then
    if [ "$cur_mnt" -ge "$on_mnt" ] && [ "$cur_mnt" -lt "$off_mnt" ]; then
        in_range=true
    fi
else
    if [ "$cur_mnt" -ge "$on_mnt" ] || [ "$cur_mnt" -lt "$off_mnt" ]; then
        in_range=true
    fi
fi

if $in_range; then
    xsct 3500 >/dev/null 2>&1
else
    xsct 0 >/dev/null 2>&1
fi
