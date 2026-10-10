#!/bin/bash

MAIN_MENU="$HOME/willyhorizont.github.io/linux/tui6-powr.sh"
CFG="$HOME/willyhorizont.github.io/.config/blu-lght-fltr.conf"
CFG_DIR=$(dirname "$CFG")
OVERRIDE_FILE="/tmp/blu-lght-fltr-override"

is_auto_on() {
    if [ "$V_AUTO" != "True" ]; then
        echo "false"
        return
    fi
    on_mnt=$(date -d "$V_ON" +"%H*60+%M" | bc)
    off_mnt=$(date -d "$V_OFF" +"%H*60+%M" | bc)
    cur_mnt=$(date +"%H*60+%M" | bc)
    if [ "$on_mnt" -lt "$off_mnt" ]; then
        if [ "$cur_mnt" -ge "$on_mnt" ] && [ "$cur_mnt" -lt "$off_mnt" ]; then
            echo "true"; return
        fi
    else
        if [ "$cur_mnt" -ge "$on_mnt" ] || [ "$cur_mnt" -lt "$off_mnt" ]; then
            echo "true"; return
        fi
    fi
    echo "false"
}

while true; do
    clear
    if [ ! -f "$CFG" ]; then
        mkdir -p "$CFG_DIR"
        cat << EOF > "$CFG"
auto_toggle_blue_light_filter = False
turn_on_at = 06:00 PM
turn_off_at = 06:00 AM
EOF
    fi
    V_AUTO=$(grep -E '^auto_toggle_blue_light_filter' "$CFG" | sed 's/[[:space:]]//g' | cut -d= -f2)
    V_ON=$(grep -E '^turn_on_at' "$CFG" | cut -d= -f2 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    V_OFF=$(grep -E '^turn_off_at' "$CFG" | cut -d= -f2 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    if [ -f "$OVERRIDE_FILE" ]; then
        V_OVERRIDE=$(cat "$OVERRIDE_FILE")
    else
        V_OVERRIDE="None"
    fi

    CUR_SCRN_TEMP=$(xsct 2>/dev/null | grep -oP 'temperature ~ \K[0-9]+')
    CUR_SCRN_TEMP=${CUR_SCRN_TEMP:-6500}

    if [ "$CUR_SCRN_TEMP" -eq 3500 ]; then
        if [ "$V_OVERRIDE" = "ON" ]; then
            STAT_FLTR="[ 🟢 ON until reboot (${CUR_SCRN_TEMP}K) ]"
        else
            STAT_FLTR="[ 🟢 ON (${CUR_SCRN_TEMP}K) ]"
        fi
        TOGGLE_TEXT="y) Turn Filter OFF Manual (Normal)"
    else
        if [ "$V_OVERRIDE" = "OFF" ]; then
            STAT_FLTR="[ 🔴 OFF until reboot (Normal) ]"
        else
            STAT_FLTR="[ 🔴 OFF (Normal) ]"
        fi
        TOGGLE_TEXT="y) Turn Filter ON Manual (3500K)"
    fi

    STAT_AUTO="[ 🔴 OFF ]"
    if [ "$V_AUTO" = "True" ]; then
        STAT_AUTO="[ 🟢 ON ]"
    fi

    echo "======================================="
    echo "     BLUE LIGHT FILTER CONTROL TUI     "
    echo "======================================="
    echo " Screen Filter Status   : $STAT_FLTR"
    echo " Auto Blue Light Filter : $STAT_AUTO"
    echo " Schedule Time          : $V_ON - $V_OFF"
    echo "---------------------------------------"
    echo " $TOGGLE_TEXT"
    echo " a) Toggle Auto Blue Light Filter ($V_ON - $V_OFF)"
    echo " q) Go Back to Main Menu"
    echo "======================================="
    echo -n " Select choice: "
    read -n 1 CHOICE

    case "$CHOICE" in
        [yY])
            if [ "$CUR_SCRN_TEMP" -eq 3500 ]; then
                xsct 0 >/dev/null 2>&1
                if [ "$(is_auto_on)" = "false" ]; then
                    rm -f "$OVERRIDE_FILE"
                else
                    echo "OFF" > "$OVERRIDE_FILE"
                fi
            else
                xsct 3500 >/dev/null 2>&1
                if [ "$(is_auto_on)" = "true" ]; then
                    rm -f "$OVERRIDE_FILE"
                else
                    echo "ON" > "$OVERRIDE_FILE"
                fi
            fi
            ;;
        [aA])
            echo -e "\n---------------------------------------"
            if [ "$V_AUTO" = "True" ]; then
                sed -i "s|^auto_toggle_blue_light_filter[[:space:]]*=.*|auto_toggle_blue_light_filter = False|" "$CFG"
                echo "[+] Auto Filter turned OFF."
            else
                sed -i "s|^auto_toggle_blue_light_filter[[:space:]]*=.*|auto_toggle_blue_light_filter = True|" "$CFG"
                echo "[+] Auto Filter turned ON."
                bash -c "$HOME/willyhorizont.github.io/linux/blu-lght-fltr.sh" >/dev/null 2>&1 &
            fi
            rm -f "$OVERRIDE_FILE"
            read -rsp "Press any key to continue..." -n 1
            ;;
        [qQ])
            exec bash "$MAIN_MENU"
            ;;
        *)
            echo -e "\n\n[!] Invalid choice!"
            read -rsp "Press any key to continue..." -n 1
            ;;
    esac
done
