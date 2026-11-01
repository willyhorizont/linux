#!/bin/bash

MAIN_MENU="$HOME/willyhorizont.github.io/linux/powr-mgr.sh"

while true; do
    clear
    CURRENT=$(powerprofilesctl get 2>/dev/null)
    echo "powr-pfl-mgr.sh"
    echo "Active Profile: [ ${CURRENT:-unknown} ]"
    echo "1) Balanced (Default)"
    echo "2) Power Saver"
    echo "3) Performance"
    echo "0) Go Back to Main Menu"
    echo "q) Exit"
    echo -n "Select mode (Default: 1): "
    read -n 1 CHOICE
    CHOICE=${CHOICE:-1}
    case "$CHOICE" in
        1) MODE="balanced" ;;
        2) MODE="power-saver" ;;
        3) MODE="performance" ;;
        0) 
            echo ""
            exec bash "$MAIN_MENU" 
            ;;
        [qQ])
            echo ""
            exit 0
            ;;
        *) 
            echo ""
            echo "Invalid choice!"
            read -rsp "Press any key to continue..." -n 1
            continue
            ;;
    esac
    echo ""
    if powerprofilesctl set "$MODE" 2>/dev/null; then
        echo "Successfully set to ${MODE^^} mode."
    else
        echo "Failed! ${MODE^^} mode is not supported on this device."
    fi
    read -rsp "Press any key to continue..." -n 1
done
