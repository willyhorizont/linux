#!/bin/bash

echo "======================================="
echo "          BLUETOOTH STATUS TUI         "
echo "======================================="

HW_AVAIL="no"
if [ -z "$(ls /sys/class/bluetooth/ 2>/dev/null)" ]; then
    echo " Hardware Status  : [ ❌ Not Found / Disabled ]"
    echo " Connected Device : [ None ]"
    HW_AVAIL="no"
else
    HW_AVAIL="yes"
    if rfkill list bluetooth | grep -q "Soft blocked: yes"; then
        echo " Hardware Status  : [ 🚫 OFF ]"
        echo " Connected Device : [ None ]"
    else
        echo " Hardware Status  : [ 🔵 ON ]"
        CONN_DIR=$(ls -d /sys/class/bluetooth/hci0/dev_* 2>/dev/null | head -n1)
        if [ -z "$CONN_DIR" ]; then
            echo " Connected Device : [ Not Connected ]"
        else
            CONN_MAC=$(basename "$CONN_DIR" | sed 's/dev_//; s/_/:/g')
            FULL_NAME=$(bluetoothctl info "$CONN_MAC" 2>/dev/null | awk -F': ' '/Name:/ {print $2}')
            DVC=${FULL_NAME:0:8}
            echo " Connected Device : [ ${DVC:-Unknown} ]"
        fi
    fi
fi

echo "======================================="

if [ "$HW_AVAIL" = "no" ]; then
    read -rsp "Press Enter to close this window..."
    echo ""
    exit 1
fi

read -p "Press Enter to open interactive bluetoothctl bluez wizard..."

echo -e "\n[*] Launching bluetoothctl bluez wizard..."
echo "---------------------------------------"

echo "[*] Ensuring bluetooth is ON..."
bluetoothctl power on >/dev/null 2>&1

echo "[*] Scanning for devices... Please wait..."
bluetoothctl scan on >/dev/null 2>&1 &
SCAN_PID=$!
sleep 5
kill $SCAN_PID >/dev/null 2>&1
bluetoothctl scan off >/dev/null 2>&1

echo -e "\nDevices found:"
echo "---------------------------------------"

mapfile -t LDVC < <(bluetoothctl devices | grep -E '[0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2}){5}' | awk '{print $2, substr($0, index($0,$3))}')

if [ ${#LDVC[@]} -eq 0 ]; then
    echo "[!] No devices found."
else
    for i in "${!LDVC[@]}"; do
        echo " [$i] ${LDVC[$i]}"
    done
    echo "---------------------------------------"
    
    read -p "Select device number to pair & connect: " DEV_IDX
    
    if [[ -n "$DEV_IDX" && "$DEV_IDX" =~ ^[0-9]+$ && $DEV_IDX -lt ${#LDVC[@]} ]]; then
        SEL_MAC=$(echo "${LDVC[$DEV_IDX]}" | awk '{print $1}')
        SEL_NM=$(echo "${LDVC[$DEV_IDX]}" | cut -d' ' -f2-)

        echo -e "\n[*] Connecting to: $SEL_NM ($SEL_MAC)"
        echo "---------------------------------------"
        
        echo "[*] Pairing..."
        bluetoothctl pair "$SEL_MAC"
        
        echo "[*] Trusting..."
        bluetoothctl trust "$SEL_MAC"
        
        echo "[*] Connecting..."
        bluetoothctl connect "$SEL_MAC"
    else
        echo -e "\n[❌] Invalid selection!"
    fi
fi

echo "---------------------------------------"
read -rsp "Press Enter to close this window..."
echo ""
exit 0
