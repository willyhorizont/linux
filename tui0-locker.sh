#!/bin/bash

LOKD="$HOME/willyhorizont.github.io/linux/lockerd.sh"
CFG="$HOME/willyhorizont.github.io/.config/lockerd.conf"
CFG_DIR=$(dirname "$CFG")

init_conf() {
    if [ ! -f "$CFG" ]; then
        mkdir -p "$CFG_DIR"
        cat << EOF > "$CFG"
idle_time_in_sec = 120
lock_time_in_minute = 4
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
        setsid bash -c "$HOME/willyhorizont.github.io/linux-debian-lxde/restart-desktop.sh" >/dev/null 2>&1 &
        echo -e "\n[+] Daemon reloaded with new configuration successfully."
        read -rsp "Press any key to continue..." -n 1
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
    echo " Idle Timeout      : $V_IDLE sec"
    echo " Auto-Lock Timeout : $V_LOCK mnt"
    echo " Show Tux          : $V_TUX"
    echo "---------------------------------------"
    echo " 1) Change Idle Timeout"
    echo " 2) Change Auto-Lock Timeout"
    echo " 3) Toggle Show Tux"
    echo " 0) Exit"
    echo "======================================="
    echo -n " Select choice: "
    read -n 1 CHOICE

    case "$CHOICE" in
        1)
            echo -e "\n---------------------------------------"
            read -p "Enter new idle time (sec): " NEW_IDLE
            if echo "$NEW_IDLE" | grep -qE '^[0-9]+$'; then
                sed -i "s|^idle_time_in_sec[[:space:]]*=.*|idle_time_in_sec = $NEW_IDLE|" "$CFG"
                echo "[+] Idle time updated to $NEW_IDLE sec."
                re_dmn
            else
                echo "[!] Error: Invalid input!"
                read -rsp "Press any key to continue..." -n 1
            fi
            ;;
        2)
            echo -e "\n---------------------------------------"
            read -p "Enter new auto-lock time (mnt): " NEW_LOCK
            if echo "$NEW_LOCK" | grep -qE '^[0-9]+$'; then
                sed -i "s|^lock_time_in_minute[[:space:]]*=.*|lock_time_in_minute = $NEW_LOCK|" "$CFG"
                echo "[+] Auto-lock time updated to $NEW_LOCK mnt."
                re_dmn
            else
                echo "[!] Error: Invalid input!"
                read -rsp "Press any key to continue..." -n 1
            fi
            ;;
        3)
            if [ "$V_TUX" = "True" ]; then
                sed -i "s|^show_tux[[:space:]]*=.*|show_tux = False|" "$CFG"
                echo -e "\n\n[-] Tux turned OFF."
            else
                sed -i "s|^show_tux[[:space:]]*=.*|show_tux = True|" "$CFG"
                echo -e "\n\n[+] Tux turned ON."
            fi
            re_dmn
            ;;
        0)
            exit 0
            ;;
        *)
            echo -e "\n\n[!] Invalid option!"
            read -rsp "Press any key to continue..." -n 1
            ;;
    esac
done
