#!/bin/bash

while true; do
    clear
    echo "======================================="
    echo "           NETWORK STATUS TUI          "
    echo "======================================="

    CON_TYPE=$(nmcli -t -f TYPE,STATE dev | awk -F: '$2=="connected" {print $1; exit}')

    if [ "$CON_TYPE" = "ethernet" ]; then 
        echo " Network Status : [ 🔌 ]"
    elif [ "$CON_TYPE" = "wifi" ]; then 
        WIFI_INFO=$(nmcli -t -f active,ssid,signal dev wifi | awk -F: '/^yes:/ {print $2 "," $3}')
        SSID=${WIFI_INFO%,*}
        SIG=${WIFI_INFO#*,}
        echo " Network Status  : [ 🛜 ${SSID:-Unknown} ${SIG:-0}% ]"
    else 
        echo " Network Status  : [ 🌐 None ]"
    fi
    echo "======================================="
    echo " 1) Open Network Manager Wizard (nmtui)"
    echo " 0) Exit"
    echo "======================================="
    echo -n " Select choice: "
    read -n 1 CHOICE

    case "$CHOICE" in
        1)
            nmtui
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
