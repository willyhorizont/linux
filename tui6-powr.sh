#!/bin/bash

POWR_PFL_SCRIPT="$HOME/willyhorizont.github.io/linux/tui6-1-powr-pfl.sh"
BRGHTNSS_SCRIPT="$HOME/willyhorizont.github.io/linux/tui6-2-brghtnss.sh"
BLU_LGHT_FLTR_SCRIPT="$HOME/willyhorizont.github.io/linux/tui6-3-blu-lght-fltr.sh"
THINKPAD_BAT_SCRIPT="$HOME/willyhorizont.github.io/linux/tui6-4-bat-lenovo-thinkpad.sh"

while true; do
    clear
    THINKPAD_SUPPORTED=false
    for b in /sys/class/power_supply/BAT*; do
        if [ -f "$b/charge_control_start_threshold" ] && [ -f "$b/charge_control_end_threshold" ]; then
            THINKPAD_SUPPORTED=true
            break
        fi
    done

    echo "======================================="
    echo "          POWER MANAGEMENT TUI         "
    echo "======================================="
    echo " 1) Power Profiles Management"
    echo " 2) Brightness Control"
    echo " 3) Blue Light Filter Control"
    if $THINKPAD_SUPPORTED; then
        echo " 4) ThinkPad Battery Threshold Management"
    fi
    echo " 0) Exit"
    echo "======================================="
    echo -n " Select choice [0-4]: "
    read -n 1 CHOICE

    case "$CHOICE" in
        1)
            if [ -f "$POWR_PFL_SCRIPT" ]; then
                exec bash "$POWR_PFL_SCRIPT"
            else
                echo -e "\n\n[!] Error: $POWR_PFL_SCRIPT not found!"
                read -rsp "Press any key to continue..." -n 1
            fi
            ;;
        2)
            if [ -f "$BRGHTNSS_SCRIPT" ]; then
                exec bash "$BRGHTNSS_SCRIPT"
            else
                echo -e "\n\n[!] Error: $BRGHTNSS_SCRIPT not found!"
                read -rsp "Press any key to continue..." -n 1
            fi
            ;;
        3)
            if [ -f "$BLU_LGHT_FLTR_SCRIPT" ]; then
                exec bash "$BLU_LGHT_FLTR_SCRIPT"
            else
                echo -e "\n\n[!] Error: $BLU_LGHT_FLTR_SCRIPT not found!"
                read -rsp "Press any key to continue..." -n 1
            fi
            ;;
        4)
            if $THINKPAD_SUPPORTED; then
                if [ -f "$THINKPAD_BAT_SCRIPT" ]; then
                    exec bash "$THINKPAD_BAT_SCRIPT"
                else
                    echo -e "\n\n[!] Error: $THINKPAD_BAT_SCRIPT not found!"
                    read -rsp "Press any key to continue..." -n 1
                fi
            else
                echo -e "\n\n[!] Invalid choice!."
                read -rsp "Press any key to continue..." -n 1
            fi
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
