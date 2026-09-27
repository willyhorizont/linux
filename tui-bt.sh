#!/bin/bash

echo "======================================="
echo "          BLUETOOTH STATUS TUI         "
echo "======================================="

IS_AVAILABLE=$(ls /sys/class/bluetooth/ 2>/dev/null)
IS_POWERED=$(timeout 1.5 bluetoothctl show 2>/dev/null | grep 'Powered: yes')

if [ -z "$IS_AVAILABLE" ] || [ -z "$IS_POWERED" ]; then 
    echo " Power Status    : [ 🔴 OFF ]"
    echo " Connected Device: [ None ]"
else 
    echo " Power Status    : [ 🟢 ON ]"
    CONN_MAC=$(timeout 1.5 bluetoothctl devices Connected 2>/dev/null | awk 'NR==1 {print $2}')
    if [ -z "$CONN_MAC" ]; then 
        echo " Connected Device: [ 🔵 Not Connected ]"
    else 
        FULL_NAME=$(timeout 1.5 bluetoothctl info "$CONN_MAC" 2>/dev/null | awk -F': ' '/Name:/ {print $2}')
        DEVICE=${FULL_NAME:0:8}
        echo " Connected Device: [ 🟢 ${DEVICE:-Unknown} ]"
    fi
fi

echo "======================================="
read -p "Press Enter to open blueman-manager..."

echo -e "Launching blueman-manager..."
echo "---------------------------------------"

if command -v blueman-manager >/dev/null 2>&1; then
    blueman-manager
else
    echo "blueman-manager not found"
fi

echo "---------------------------------------"
read -rsp "Press Enter to close this window..."
exit 0
