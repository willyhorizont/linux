#!/bin/bash

POWR_PFL_SCRIPT="$HOME/willyhorizont.github.io/linux/powr-pfl-mgr.sh"
BRGHTNSS_SCRIPT="$HOME/willyhorizont.github.io/linux/scrn-brghtnss-mgr.sh"
BLU_LGHT_FLTR_SCRIPT="$HOME/willyhorizont.github.io/linux/blu-lght-fltr-mgr.sh"
THINKPAD_BAT_SCRIPT="$HOME/willyhorizont.github.io/linux/bat-lenovo-thinkpad-mgr.sh"

while true; do
    clear
    THINKPAD_SUPPORTED=false
    for b in /sys/class/power_supply/BAT*; do
        if [ -f "$b/charge_control_start_threshold" ] && [ -f "$b/charge_control_end_threshold" ]; then
            THINKPAD_SUPPORTED=true
            break
        fi
    done
    echo "powr-mgr.sh"
    echo "1) Brightness"
    echo "2) Blue Light Filter"
    echo "3) Power Profiles"
    if $THINKPAD_SUPPORTED; then
        echo "4) ThinkPad Battery Charge Threshold"
    fi
    echo "q) Exit"
    echo -n "Select choice: "
    read -n 1 CHOICE
    case "$CHOICE" in
        1)
            if [ -f "$BRGHTNSS_SCRIPT" ]; then
                exec bash "$BRGHTNSS_SCRIPT"
            else
                echo -e "\nError: $BRGHTNSS_SCRIPT not found!"
                read -rsp "Press any key to continue..." -n 1
            fi
            ;;
        2)
            if [ -f "$BLU_LGHT_FLTR_SCRIPT" ]; then
                exec bash "$BLU_LGHT_FLTR_SCRIPT"
            else
                echo -e "\nError: $BLU_LGHT_FLTR_SCRIPT not found!"
                read -rsp "Press any key to continue..." -n 1
            fi
            ;;
        3)
            if [ -f "$POWR_PFL_SCRIPT" ]; then
                exec bash "$POWR_PFL_SCRIPT"
            else
                echo -e "\nError: $POWR_PFL_SCRIPT not found!"
                read -rsp "Press any key to continue..." -n 1
            fi
            ;;
        4)
            if $THINKPAD_SUPPORTED; then
                if [ -f "$THINKPAD_BAT_SCRIPT" ]; then
                    exec bash "$THINKPAD_BAT_SCRIPT"
                else
                    echo -e "\nError: $THINKPAD_BAT_SCRIPT not found!"
                    read -rsp "Press any key to continue..." -n 1
                fi
            else
                echo -e "\nInvalid choice!."
                read -rsp "Press any key to continue..." -n 1
            fi
            ;;
        [Qq])
            exit 0
            ;;
        *)
            echo -e "\nInvalid choice!"
            read -rsp "Press any key to continue..." -n 1
            ;;
    esac
done
