#!/bin/bash

while true; do
    clear
    echo "======================================="
    echo "           CAMERA STATUS TUI           "
    echo "======================================="

    STATUS_FILE="/sys/class/video4linux/video0/device/power/runtime_status"

    if [ ! -f "$STATUS_FILE" ]; then
        echo " Hardware Status : [ 🚫 Disabled ]"
        echo " Active App      : [ None ]"
        HW_CONNECTED=false
        TOGGLE_TXT="1) Enable Camera Module"
    else
        HW_CONNECTED=true
        read -r STATUS < "$STATUS_FILE"
        
        if [ "$STATUS" = "active" ]; then
            echo " Hardware Status : [ 👁️ ON / Active ]"
            CAM_PID=$(lsof -t /dev/video0 2>/dev/null | head -n1)
            if [ -n "$CAM_PID" ]; then
                APP_NAME=$(ps -p "$CAM_PID" -o comm= 2>/dev/null)
                echo " Active App      : [ 👁️ ${APP_NAME:-Unknown} (PID: $CAM_PID) ]"
            else
                echo " Active App      : [ ⏳ Accessing... ]"
            fi
        else
            echo " Hardware Status : [ ⚠️  Standby / Idle / Sleep ]"
            echo " Active App      : [ None ]"
        fi
        TOGGLE_TXT="1) Disable Camera Module"
    fi
    echo "======================================="
    echo " $TOGGLE_TXT"
    echo " 0) Exit"
    echo "======================================="
    echo -n " Select choice: "
    read -n 1 CHOICE

    case "$CHOICE" in
        1)
            if $HW_CONNECTED; then
                echo -e "\n\n[!] Disabling camera hardware module..."
                echo "---------------------------------------"
                if sudo modprobe -r uvcvideo 2>/dev/null; then
                    echo "[+] Camera successfully turned OFF."
                else
                    echo "[!] Failed! Camera busy or invalid password."
                fi
            else
                echo -e "\n\n[+] Enabling camera hardware module..."
                echo "---------------------------------------"
                if sudo modprobe uvcvideo 2>/dev/null; then
                    echo "[+] Camera successfully turned ON."
                else
                    echo "[!] Failed! Could not load uvcvideo kernel driver."
                fi
            fi
            read -rsp "Press any key to continue..." -n 1
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
