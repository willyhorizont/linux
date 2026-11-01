#!/bin/bash

MAIN_MENU="$HOME/willyhorizont.github.io/linux/powr-mgr.sh"

while true; do
    clear
    RAW_BRGHTNSS=$(( $(brightnessctl get) * 100 / $(brightnessctl max) ))
    CUR_BRGHTNSS=$(( (RAW_BRGHTNSS + 5) / 10 * 10 ))
    echo "scrn-brghtnss-mgr.sh"
    echo "Current Brightness : [ ☀️ ${CUR_BRGHTNSS}% ]"
    echo "y) Increase Brightness (+10%)"
    echo "n) Decrease Brightness (-10%)"
    echo "0) Go Back to Main Menu"
    echo "q) Exit"
    echo -n "Select choice: "
    read -n 1 CHOICE
    case "$CHOICE" in
        [Yy])
            echo ""
            NEW_BRGHTNSS=$(( CUR_BRGHTNSS + 10 ))
            if [ "$NEW_BRGHTNSS" -gt 100 ]; then NEW_BRGHTNSS=100; fi
            brightnessctl set ${NEW_BRGHTNSS}% >/dev/null 2>&1
            ;;
        [Nn])
            echo ""
            NEW_BRGHTNSS=$(( CUR_BRGHTNSS - 10 ))
            if [ "$NEW_BRGHTNSS" -lt 0 ]; then NEW_BRGHTNSS=0; fi
            brightnessctl set ${NEW_BRGHTNSS}% >/dev/null 2>&1
            ;;
        0)
            echo ""
            exec bash "$MAIN_MENU"
            ;;
        [Qq])
            echo ""
            exit 0
            ;;
        *)
            echo ""
            echo "Invalid choice!"
            read -rsp "Press any key to continue..." -n 1
            ;;
    esac
done
