#!/bin/bash

MAIN_MENU="$HOME/willyhorizont.github.io/linux/tui6-powr.sh"

while true; do
    clear
    RAW_BRGHTNSS=$(( $(brightnessctl get) * 100 / $(brightnessctl max) ))
    CUR_BRGHTNSS=$(( (RAW_BRGHTNSS + 5) / 10 * 10 ))

    echo "======================================="
    echo "          BRIGHTNESS CONTROL TUI       "
    echo "======================================="
    echo " Current Brightness : [ ☀️ ${CUR_BRGHTNSS}% ]"
    echo "---------------------------------------"
    echo " y) Increase Brightness (+10%)"
    echo " n) Decrease Brightness (-10%)"
    echo " q) Go Back to Main Menu"
    echo "======================================="
    echo -n " Select choice: "
    read -n 1 CHOICE

    case "$CHOICE" in
        [Yy])
            NEW_BRGHTNSS=$(( CUR_BRGHTNSS + 10 ))
            if [ "$NEW_BRGHTNSS" -gt 100 ]; then NEW_BRGHTNSS=100; fi
            brightnessctl set ${NEW_BRGHTNSS}% >/dev/null 2>&1
            ;;
        [Nn])
            NEW_BRGHTNSS=$(( CUR_BRGHTNSS - 10 ))
            if [ "$NEW_BRGHTNSS" -lt 0 ]; then NEW_BRGHTNSS=0; fi
            brightnessctl set ${NEW_BRGHTNSS}% >/dev/null 2>&1
            ;;
        [Qq])
            exec bash "$MAIN_MENU"
            ;;
        *)
            echo -e "\n\n[!] Invalid choice!"
            read -rsp "Press any key to continue..." -n 1
            ;;
    esac
done
