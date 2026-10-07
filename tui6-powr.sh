#!/bin/bash

echo "======================================="
echo "          POWER MANAGEMENT TUI         "
echo "======================================="

POWR_PFL_SCRIPT="$HOME/willyhorizont.github.io/linux/tui-powr-pfl.sh"
THINKPAD_BAT_SCRIPT="$HOME/willyhorizont.github.io/linux/tui-bat-lenovo-thinkpad.sh"

THINKPAD_SUPPORTED=false
for b in /sys/class/power_supply/BAT*; do
    if [ -f "$b/charge_control_start_threshold" ] && [ -f "$b/charge_control_end_threshold" ]; then
        THINKPAD_SUPPORTED=true
        break
    fi
done

echo " 1) Power Profiles Management"
if $THINKPAD_SUPPORTED; then
    echo " 2) ThinkPad Battery Threshold Management"
fi
echo "======================================="
read -p " Select choice (Default: 1): " CHOICE

CHOICE=${CHOICE:-1}

case "$CHOICE" in
    1)
        if [ -f "$POWR_PFL_SCRIPT" ]; then
            echo -e "\n[*] Launching Power Profiles TUI..."
            echo "---------------------------------------"
            bash -c "$POWR_PFL_SCRIPT"
        else
            echo -e "\n[!] Error: $POWR_PFL_SCRIPT not found!"
            echo "---------------------------------------"
            read -rsp "Press Enter to close..."
            exit 1
        fi
        ;;
    2)
        if $THINKPAD_SUPPORTED; then
            if [ -f "$THINKPAD_BAT_SCRIPT" ]; then
                echo -e "\n[*] Launching ThinkPad Battery TUI..."
                echo "---------------------------------------"
                bash -c "$THINKPAD_BAT_SCRIPT"
            else
                echo -e "\n[!] Error: $THINKPAD_BAT_SCRIPT not found!"
                echo "---------------------------------------"
                read -rsp "Press Enter to close..."
                exit 1
            fi
        else
            echo -e "\n[!] Invalid choice! Option 2 is not supported on this hardware."
            echo "---------------------------------------"
            read -rsp "Press Enter to close..."
            exit 1
        fi
        ;;
    *)
        echo -e "\n[!] Invalid choice! No changes made."
        echo "---------------------------------------"
        read -rsp "Press Enter to close..."
        exit 1
        ;;
esac
echo "---------------------------------------"
read -rsp "Press Enter to close this window..."
echo ""
exit 0
