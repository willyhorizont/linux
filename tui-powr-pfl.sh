#!/bin/bash

CURRENT=$(powerprofilesctl get 2>/dev/null)

echo "======================================="
echo "          POWER PROFILES TUI           "
echo "======================================="
echo " Active Profile: [ ${CURRENT:-unknown} ]"
echo "---------------------------------------"
echo " 1) Balanced (Default)"
echo " 2) Power Saver"
echo " 3) Performance"
echo "======================================="
read -p " Select mode [1-3] (Default: 1): " CHOICE

CHOICE=${CHOICE:-1}

case "$CHOICE" in
    1) MODE="balanced" ;;
    2) MODE="power-saver" ;;
    3) MODE="performance" ;;
    *) echo -e "\n[!] Invalid choice! No changes made."; exit 1 ;;
esac

if powerprofilesctl set "$MODE" 2>/dev/null; then
    echo -e "\n[+] Successfully set to ${MODE^^} mode."
else
    echo -e "\n[!] Failed! ${MODE^^} mode is not supported on this hardware."
fi

echo "---------------------------------------"
read -rsp "Press any key to close this window..."
echo ""
exit 0
