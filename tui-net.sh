#!/bin/bash

echo "======================================="
echo "           NETWORK STATUS TUI          "
echo "======================================="

CON_TYPE=$(nmcli -t -f TYPE,STATE dev | awk -F: '$2=="connected" {print $1; exit}')

if [ "$CON_TYPE" = "ethernet" ]; then 
    echo " Connection Type : [ 🌐 Wired ]"
    echo " Network Status  : [ 🟢 Ethernet ]"
elif [ "$CON_TYPE" = "wifi" ]; then 
    WIFI_INFO=$(nmcli -t -f active,ssid,signal dev wifi | awk -F: '/^yes:/ {print $2 "," $3}')
    SSID=${WIFI_INFO%,*}
    SIG=${WIFI_INFO#*,}
    echo " Connection Type : [ 🛜 WiFi ]"
    echo " Network Status  : [ 🟢 ${SSID:-Unknown} ${SIG:-0}% ]"
else 
    echo " Connection Type : [ 🌐 None ]"
    echo " Network Status  : [ 🔴 None ]"
fi

echo "======================================="
read -p "Press Enter to open nmtui..."

echo -e "\n[*] Launching nmtui..."
echo "---------------------------------------"
nmtui
echo "---------------------------------------"

read -rsp "Press any key to close this window..."
echo ""
exit 0
