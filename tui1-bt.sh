#!/bin/bash

echo "======================================="
echo "          BLUETOOTH STATUS TUI         "
echo "======================================="

if [ -z "$(ls /sys/class/bluetooth/ 2>/dev/null)" ]; then
    echo " Power Status    : [ ❌ Not Found / Disabled ]"
    echo " Connected Device: [ None ]"
else
    if rfkill list bluetooth | grep -q "Soft blocked: yes"; then
        echo " Power Status    : [ 🚫 OFF ]"
        echo " Connected Device: [ None ]"
    else
        echo " Power Status    : [ 🔵 ON ]"
        CONN_DIR=$(ls -d /sys/class/bluetooth/hci0/dev_* 2>/dev/null | head -n1)
        if [ -z "$CONN_DIR" ]; then
            echo " Connected Device: [ Not Connected ]"
        else
            CONN_MAC=$(basename "$CONN_DIR" | sed 's/dev_//; s/_/:/g')
            FULL_NAME=$(bluetoothctl info "$CONN_MAC" 2>/dev/null | awk -F': ' '/Name:/ {print $2}')
            DEVICE=${FULL_NAME:0:8}
            echo " Connected Device: [ ${DEVICE:-Unknown} ]"
        fi
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
