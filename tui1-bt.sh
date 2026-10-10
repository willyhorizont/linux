#!/bin/bash

while true; do
    clear
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
    echo " 1) Open interactive bluetoothctl bluez wizard"
    echo " 0) Exit"
    echo "======================================="
    echo -n " Select choice: "
    read -n 1 CHOICE

    case "$CHOICE" in
        1)
            if [ "$HW_AVAIL" = "no" ]; then
                echo -e "\n\n[!] Error: Bluetooth hardware not available."
                read -rsp "Press any key to continue..." -n 1
                continue
            fi
            
            echo -e "\n\n[*] Powering ON bluetooth..."
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
                read -rsp "Press any key to continue..." -n 1
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
                    bluetoothctl pair "$SEL_MAC"
                    bluetoothctl trust "$SEL_MAC"
                    bluetoothctl connect "$SEL_MAC"
                    read -rsp "Press any key to continue..." -n 1
                else
                    echo -e "\n[!] Invalid choice!"
                    read -rsp "Press any key to continue..." -n 1
                fi
            fi
            ;;
        0)
            exit 0
            ;;
        *)
            echo -e "\n\n[!] Invalid choice!"
            read -rsp "Press any key to continue..." -n 1
            ;;
    esac
done
