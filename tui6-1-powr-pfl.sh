#!/bin/bash

MAIN_MENU="$HOME/willyhorizont.github.io/linux/tui6-powr.sh"

while true; do
    clear
    CURRENT=$(powerprofilesctl get 2>/dev/null)

    echo "======================================="
    echo "          POWER PROFILES TUI           "
    echo "======================================="
    echo " Active Profile: [ ${CURRENT:-unknown} ]"
    echo "---------------------------------------"
    echo " 1) Balanced (Default)"
    echo " 2) Power Saver"
    echo " 3) Performance"
    echo " 0) Go Back to Main Menu"
    echo "======================================="
    echo -n " Select mode (Default: 1): "
    read -n 1 CHOICE

    CHOICE=${CHOICE:-1}

    case "$CHOICE" in
        1) MODE="balanced" ;;
        2) MODE="power-saver" ;;
        3) MODE="performance" ;;
        0) 
            exec bash "$MAIN_MENU" 
            ;;
        *) 
            echo -e "\n\n[!] Invalid choice!"
            read -rsp "Press any key to continue..." -n 1
            continue
            ;;
    esac

    if powerprofilesctl set "$MODE" 2>/dev/null; then
        echo -e "\n\n[+] Successfully set to ${MODE^^} mode."
    else
        echo -e "\n\n[!] Failed! ${MODE^^} mode is not supported on this hardware."
    fi
    read -rsp "Press any key to continue..." -n 1
done
