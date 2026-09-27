#!/bin/bash

CON_TYPE=$(nmcli -t -f TYPE,STATE dev | awk -F: '$2=="connected" {print $1; exit}')

if [ "$CON_TYPE" = "ethernet" ]; then
    echo "[net=ethernet ]"
elif [ "$CON_TYPE" = "wifi" ]; then
    SIG=$(nmcli -t -f active,ssid,signal dev wifi | awk -F: '/^yes:/ {print $3}')
    SIG_PAD=$(printf "%3d" "${SIG:-0}")
    echo "[net=wifi $SIG_PAD%]"
else
    echo "[net=x        ]"
fi
