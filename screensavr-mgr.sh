#!/bin/bash

DMN_SCRNSVR="$HOME/willyhorizont.github.io/linux/dmn-screensavr.sh"
CFG="$HOME/willyhorizont.github.io/.config/dmn-screensavr.conf"
CFG_DIR=$(dirname "$CFG")

while true; do
    clear
    if [ ! -f "$CFG" ]; then
        mkdir -p "$CFG_DIR"
        cat << EOF > "$CFG"
idle_time_in_sec = 120
show_tux = True
show_window = True
EOF
    fi
    V_IDLE=$(grep -E '^idle_time_in_sec' "$CFG" | sed 's/[[:space:]]//g' | cut -d= -f2)
    V_TUX=$(grep -E '^show_tux' "$CFG" | sed 's/[[:space:]]//g' | cut -d= -f2)
    V_WIN=$(grep -E '^show_window' "$CFG" | sed 's/[[:space:]]//g' | cut -d= -f2)
    DMN_STAT="🪦 INACTIVE"
    if pgrep -f "$DMN_SCRNSVR" >/dev/null; then
        DMN_STAT="🎉 ACTIVE"
    fi
    echo "screensavr-mgr.sh"
    echo "Screensaver Status : $DMN_STAT"
    echo "Idle Timeout       : $V_IDLE sec"
    echo "Show Tux           : $V_TUX"
    echo "Show Window        : $V_WIN"
    echo "1) Change Idle Timeout"
    echo "2) Toggle Show Tux"
    echo "3) Toggle Show Window"
    echo "0) Exit"
    echo -n "Select choice: "
    read -n 1 CHOICE
    case "$CHOICE" in
        1)
            echo ""
            read -p "Enter new idle time (sec): " NEW_IDLE
            if echo "$NEW_IDLE" | grep -qE '^[0-9]+$'; then
                sed -i "s|^idle_time_in_sec[[:space:]]*=.*|idle_time_in_sec = $NEW_IDLE|" "$CFG"
                echo "Idle time updated to $NEW_IDLE sec."
                echo "Please restart desktop manually."
                read -rsp "Press any key to continue..." -n 1
            else
                echo "Error: Invalid input!"
                read -rsp "Press any key to continue..." -n 1
            fi
            ;;
        2)
            if [ "$V_TUX" = "True" ]; then
                sed -i "s|^show_tux[[:space:]]*=.*|show_tux = False|" "$CFG"
                echo -e "\nShow Tux turned OFF."
            else
                sed -i "s|^show_tux[[:space:]]*=.*|show_tux = True|" "$CFG"
                echo -e "\nShow Tux turned ON."
            fi
            echo "Please restart desktop manually."
            read -rsp "Press any key to continue..." -n 1
            ;;
        3)
            if [ "$V_WIN" = "True" ]; then
                sed -i "s|^show_window[[:space:]]*=.*|show_window = False|" "$CFG"
                echo -e "\nShow Window turned OFF."
            else
                sed -i "s|^show_window[[:space:]]*=.*|show_window = True|" "$CFG"
                echo -e "\nShow Window turned ON."
            fi
            echo "Please restart desktop manually."
            read -rsp "Press any key to continue..." -n 1
            ;;
        0)
            echo ""
            exit 0
            ;;
        *)
            echo -e "\nInvalid option!"
            read -rsp "Press any key to continue..." -n 1
            ;;
    esac
done
