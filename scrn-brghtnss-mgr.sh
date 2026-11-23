#!/bin/bash

MAIN_MENU="$HOME/willyhorizont.github.io/linux/powr-mgr.sh"

get_scrn_brghtnss_percent() {
    local brghtnss=$(( $(brightnessctl get) * 100 / $(brightnessctl max) ))
    echo $(( (brghtnss + 5) / 10 * 10 ))
}

IS_PRINT_MODE=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --print)   IS_PRINT_MODE=true; shift ;;
        *)         shift ;;
    esac
done

if $IS_PRINT_MODE; then
    get_scrn_brghtnss_percent
    exit 0
fi

while true; do
    clear
    cur_brghtnss=$(get_scrn_brghtnss_percent)
    echo "scrn-brghtnss-mgr.sh"
    echo "Current Brightness : [ ☀️ ${cur_brghtnss}% ]"
    echo "y) Increase Brightness (+10%)"
    echo "n) Decrease Brightness (-10%)"
    echo "0) Go Back to Main Menu"
    echo "q) Exit"
    echo -n "Select choice: "
    read -n 1 CHOICE
    case "$CHOICE" in
        [Yy])
            echo ""
            NEW_BRGHTNSS=$(( cur_brghtnss + 10 ))
            if [ "$NEW_BRGHTNSS" -gt 100 ]; then NEW_BRGHTNSS=100; fi
            brightnessctl set ${NEW_BRGHTNSS}% >/dev/null 2>&1
            ;;
        [Nn])
            echo ""
            NEW_BRGHTNSS=$(( cur_brghtnss - 10 ))
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
