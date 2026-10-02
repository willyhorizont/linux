#!/bin/bash

echo "======================================="
echo "          TUX DAEMON STATUS TUI        "
echo "======================================="

DAEMON_SCRIPT="$HOME/willyhorizont.github.io/linux/tuxd.sh"

if pgrep -f "$DAEMON_SCRIPT" >/dev/null; then
    echo " Daemon Status    : [ 🟢 ACTIVE ]"
    if pidof xpenguins >/dev/null; then
        echo " Tux State   : [ Roaming Desktop ]"
    else
        echo " Tux State   : [ Hidden (Window Maximized) ]"
    fi
    echo "======================================="
    read -p "Press Enter to TURN OFF Tux Daemon..."
    
    echo -e "\n[!] Shutting down daemon and removing penguins..."
    echo "---------------------------------------"
    pkill -f "$DAEMON_SCRIPT" 2>/dev/null
    pkill -x xpenguins 2>/dev/null
    echo "[+] Tux Daemon successfully stopped."
else
    echo " Daemon Status    : [ 🔴 INACTIVE ]"
    echo " Tux State   : [ Terminated ]"
    echo "======================================="
    read -p "Press Enter to TURN ON Tux Daemon..."
    
    echo -e "\n[+] Unleashing background manager loop..."
    echo "---------------------------------------"
    if [ -f "$DAEMON_SCRIPT" ]; then
        nohup bash "$DAEMON_SCRIPT" >/dev/null 2>&1 &
        echo "[+] Tux Daemon successfully launched."
    else
        echo "[!] Error: File not found at $DAEMON_SCRIPT"
    fi
fi

echo "---------------------------------------"
read -rsp "Press Enter to close this window..."
echo ""
exit 0
