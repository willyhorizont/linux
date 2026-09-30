#!/bin/bash

echo " | BT=? | "

if [ -z "$(ls /sys/class/bluetooth/ 2>/dev/null)" ] || ! bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then
    echo " | BT=N | "
else
    CONN_MAC=$(bluetoothctl devices Connected 2>/dev/null | awk 'NR==1 {print $2}')
    if [ -z "$CONN_MAC" ]; then
        echo " | BT=? | "
    else
        echo " | BT=Y | "
    fi
fi
