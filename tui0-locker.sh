#!/bin/bash

LOKD="$HOME/willyhorizont.github.io/linux/lockerd.sh"
CFG="$HOME/willyhorizont.github.io/.config/lockerd.conf"
CFG_DIR=$(dirname "$CFG")

init_conf() {
    if [ ! -f "$CFG" ]; then
        mkdir -p "$CFG_DIR"
        cat << EOF > "$CFG"
idle_time_in_sec = 120
lock_time_in_minute = 5
show_tux = True
EOF
    fi
}

read_conf() {
    init_conf
    V_IDLE=$(grep -E '^idle_time_in_sec' "$CFG" | sed 's/[[:space:]]//g' | cut -d= -f2)
    V_LOCK=$(grep -E '^lock_time_in_minute' "$CFG" | sed 's/[[:space:]]//g' | cut -d= -f2)
    V_TUX=$(grep -E '^show_tux' "$CFG" | sed 's/[[:space:]]//g' | cut -d= -f2)
}

re_dmn() {
    if pgrep -f "$LOKD" >/dev/null; then
        echo "[!] Active daemon detected. Reloading with new configuration..."
        pkill -f "$LOKD" 2>/dev/null
        pkill -x "xterm" 2>/dev/null
        pkill -x "xpenguins" 2>/dev/null
        nohup bash -c "$LOKD" >/dev/null 2>&1 &
        echo "[+] Daemon reloaded successfully."
    fi
}

while true; do
    clear
    read_conf
    
    DMN_STAT="[ 🔴 INACTIVE ]"
    if pgrep -f "$LOKD" >/dev/null; then
        DMN_STAT="[ 🟢 ACTIVE ]"
    fi

    echo "======================================="
    echo "           LOCKER DAEMON TUI           "
    echo "======================================="
    echo " Daemon Status     : $DMN_STAT"
    echo " Idle Timeout      : $V_IDLE seconds"
    echo " Auto-Lock Timeout : $V_LOCK minutes"
    echo " Show Tux          : $V_TUX"
    echo "---------------------------------------"
    echo " [1] Change Idle Timeout"
    echo " [2] Change Auto-Lock Timeout"
    echo " [3] Toggle Show Tux"
    echo " [0] Exit"
    echo "======================================="
    read -p "Select option: " OPT

    case "$OPT" in
        1)
            echo "---------------------------------------"
            read -p "Enter new idle time (seconds): " NEW_IDLE
            if echo "$NEW_IDLE" | grep -qE '^[0-9]+$'; then
                sed -i "s|^idle_time_in_sec[[:space:]]*=.*|idle_time_in_sec = $NEW_IDLE|" "$CFG"
                echo "[+] Idle time updated to $NEW_IDLE seconds."
                re_dmn
            else
                echo "[!] Error: Invalid input!"
            fi
            read -rsp "Press Enter to continue..."
            ;;
        2)
            echo "---------------------------------------"
            read -p "Enter new auto-lock time (minutes): " NEW_LOCK
            if echo "$NEW_LOCK" | grep -qE '^[0-9]+$'; then
                sed -i "s|^lock_time_in_minute[[:space:]]*=.*|lock_time_in_minute = $NEW_LOCK|" "$CFG"
                echo "[+] Auto-lock time updated to $NEW_LOCK minutes."
                re_dmn
            else
                echo "[!] Error: Invalid input!"
            fi
            read -rsp "Press Enter to continue..."
            ;;
        3)
            echo "---------------------------------------"
            echo "Toggle Show Tux:"
            echo " [t] turn ON"
            echo " [f] turn OFF"
            read -p "Choice [t/f]: " TUX_CH
            case "$TUX_CH" in
                t|T)
                    sed -i "s|^show_tux[[:space:]]*=.*|show_tux = True|" "$CFG"
                    echo "[+] Tux turned ON."
                    re_dmn
                    ;;
                f|F)
                    sed -i "s|^show_tux[[:space:]]*=.*|show_tux = False|" "$CFG"
                    echo "[+] Tux turned OFF."
                    re_dmn
                    ;;
                *)
                    echo "[!] Invalid choice, skipping."
                    ;;
            esac
            read -rsp "Press Enter to continue..."
            ;;
        0)
            echo -e "\nExiting..."
            exit 0
            ;;
        *)
            echo "[!] Invalid option!"
            read -rsp "Press Enter to continue..."
            ;;
    esac
done
