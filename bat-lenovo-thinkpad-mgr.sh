#!/bin/bash

MAIN_MENU="$HOME/willyhorizont.github.io/linux/powr-mgr.sh"

while true; do
    clear
    echo "bat-lenovo-thinkpad-mgr.sh"
    BATS=()
    for b in /sys/class/power_supply/BAT*; do
        if [ -f "$b/charge_control_start_threshold" ] && [ -f "$b/charge_control_end_threshold" ]; then
            BATS+=("$(basename "$b")")
        fi
    done
    if [ ${#BATS[@]} -eq 0 ]; then
        echo "Error Status    : [ ❌ ThinkPad ACPI Not Found ]"
        echo "Description     : [ Hardware / driver not supported ]"
        read -rsp "Press any key to return to main menu..." -n 1
        exec bash "$MAIN_MENU"
    fi
    echo "Detected Batteries: [ ${BATS[*]} ]"
    for bat in "${BATS[@]}"; do
        START=$(cat "/sys/class/power_supply/$bat/charge_control_start_threshold")
        END=$(cat "/sys/class/power_supply/$bat/charge_control_end_threshold")
        echo "* $bat Threshold : [ 🔌 $START% - ❌ $END% ]"
    done
    echo "1) Balanced Mode (Start: 75%, End: 80%)"
    echo "2) Maximum Lifespan (Start: 45%, End: 50%)"
    echo "3) Full Charge Mode (Start: 96%, End: 100%)"
    echo "4) Custom Threshold Input"
    echo "0) Go Back to Main Menu"
    echo "q) Exit"
    echo -n "Select profile (Default: 1): "
    read -n 1 CHOICE
    CHOICE=${CHOICE:-1}
    case "$CHOICE" in
        1) 
            echo ""
            NEW_START=75; NEW_END=80 
            ;;
        2) 
            echo ""
            NEW_START=45; NEW_END=50 
            ;;
        3) 
            echo ""
            NEW_START=96; NEW_END=100 
            ;;
        4)
            echo ""
            read -p "Enter Start Threshold (e.g., 60): " NEW_START
            read -p "Enter End Threshold   (e.g., 85): " NEW_END
            if ! [[ "$NEW_START" =~ ^[0-9]+$ ]] || ! [[ "$NEW_END" =~ ^[0-9]+$ ]] || [ "$NEW_START" -ge "$NEW_END" ] || [ "$NEW_END" -gt 100 ]; then
                echo "Invalid input values! No changes made."
                read -rsp "Press any key to continue..." -n 1
                continue
            fi
            ;;
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
    echo "Applying battery charge thresholds..."
    SUCCESS=true
    for bat in "${BATS[@]}"; do
        START_FILE="/sys/class/power_supply/$bat/charge_control_start_threshold"
        END_FILE="/sys/class/power_supply/$bat/charge_control_end_threshold"
        if ! sudo sh -c "echo $NEW_START > $START_FILE && echo $NEW_END > $END_FILE" 2>/dev/null; then
            SUCCESS=false
        fi
    done
    if $SUCCESS; then
        echo "Successfully set ALL thresholds to ${NEW_START}% - ${NEW_END}%"
    else
        echo "Failed! Invalid password or hardware write error."
    fi
    read -rsp "Press any key to continue..." -n 1
done
