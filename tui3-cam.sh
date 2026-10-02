#!/bin/bash

echo "======================================="
echo "           CAMERA STATUS TUI           "
echo "======================================="

STATUS_FILE="/sys/class/video4linux/video0/device/power/runtime_status"

if [ ! -f "$STATUS_FILE" ]; then
    echo " Hardware Status : [ 🚫 Disabled ]"
    echo " Active App      : [ None ]"
    HW_CONNECTED=false
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
        echo " Hardware Status : [ ⚠️ Standby / Idle / Sleep ]"
        echo " Active App      : [ None ]"
    fi
fi

echo "======================================="

if $HW_CONNECTED; then
    read -p "Press Enter to DISABLE camera..."
    echo -e "\n[!] Disabling camera hardware module..."
    echo "---------------------------------------"
    if sudo modprobe -r uvcvideo 2>/dev/null; then
        echo "[+] Camera successfully turned OFF."
    else
        echo "[!] Failed! Invalid password or camera is currently busy."
    fi
else
    read -p "Press Enter to ENABLE camera..."
    echo -e "\n[+] Enabling camera hardware module..."
    echo "---------------------------------------"
    if sudo modprobe uvcvideo 2>/dev/null; then
        echo "[+] Camera successfully turned ON."
    else
        echo "[!] Failed! Could not load uvcvideo kernel driver."
    fi
fi

echo "---------------------------------------"
read -rsp "Press Enter to close this window..."
echo ""
exit 0
