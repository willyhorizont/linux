#!/bin/bash

IS_INDICATOR=false
IC_INIT="⏳"
IC_ON="🔵"
IC_OFF="🚫"
IC_NONE="❌"

PREF=" "
SUFF=" | "

while [[ $# -gt 0 ]]; do
    case "$1" in
        --indicator)   IS_INDICATOR=true; shift ;;
        --ic-init)     IC_INIT="$2";      shift 2 ;;
        --ic-on)       IC_ON="$2";        shift 2 ;;
        --ic-off)      IC_OFF="$2";       shift 2 ;;
        --ic-none)     IC_NONE="$2";      shift 2 ;;
        --pref)        PREF="$2";         shift 2 ;;
        --suff)        SUFF="$2";         shift 2 ;;
        *)                                shift ;;
    esac
done

get_bt_stat() {
    DEV_NAME="None"
    if [ -z "$(ls /sys/class/bluetooth/ 2>/dev/null)" ]; then
        STATE="NONE"
    elif rfkill list bluetooth | grep -q "Soft blocked: yes"; then
        STATE="OFF"
    else
        CONN_DIR=$(ls -d /sys/class/bluetooth/hci0/dev_* 2>/dev/null | head -n1)
        if [ -z "$CONN_DIR" ]; then
            STATE="INIT"
            DEV_NAME="Not Connected"
        else
            STATE="ON"
            local conn_mac
            conn_mac=$(basename "$CONN_DIR" | sed 's/dev_//; s/_/:/g')
            local full_name
            full_name=$(bluetoothctl info "$conn_mac" 2>/dev/null | awk -F': ' '/Name:/ {print $2}')
            DEV_NAME=${full_name:-Unknown}
        fi
    fi
}

if $IS_INDICATOR; then
    get_bt_stat
    DVC_SHORT=${DEV_NAME:0:8}
    if [ "$STATE" = "ON" ]; then
        DVC_LINE="${DEV_NAME}"
    else
        DVC_LINE=""
    fi
    TOOLTIP_TXT=$(cat << EOF
 bt.sh
 --ic-init = ${IC_INIT}
 --ic-on   = ${IC_ON}
 --ic-off  = ${IC_OFF}
 --ic-none = ${IC_NONE}
 click to open bt.sh;
 ${DVC_LINE}
EOF
    )
    case "$STATE" in
        NONE) echo "${PREF}BT=${IC_NONE}${SUFF}" ;;
        OFF)  echo "${PREF}BT=${IC_OFF}${SUFF}" ;;
        INIT) echo "${PREF}BT=${IC_INIT}${SUFF}" ;;
        ON)   echo "${PREF}BT=${IC_ON}${SUFF}" ;;
    esac
    printf "%s" "$TOOLTIP_TXT" 1>&2
    exit 0
fi

while true; do
    clear
    echo "bt.sh"
    get_bt_stat
    case "$STATE" in
        NONE)
            echo "Hardware Status  : [ ${IC_NONE} Not Found / Disabled ]"
            echo "Connected Device : [ ${DEV_NAME} ]"
            HW_AVAIL="no"
            ;;
        OFF)
            echo "Hardware Status  : [ ${IC_OFF} OFF ]"
            echo "Connected Device : [ ${DEV_NAME} ]"
            HW_AVAIL="yes"
            ;;
        INIT)
            echo "Hardware Status  : [ ${IC_ON} ON ]"
            echo "Connected Device : [ ${DEV_NAME} ]"
            HW_AVAIL="yes"
            ;;
        ON)
            echo "Hardware Status  : [ ${IC_ON} ON ]"
            echo "Connected Device : [ ${DEV_NAME} ]"
            HW_AVAIL="yes"
            ;;
    esac
    echo "1) Open interactive bluetoothctl bluez wizard"
    echo "0) Exit"
    echo -n " Select choice: "
    read -n 1 CHOICE
    case "$CHOICE" in
        1)
            if [ "$HW_AVAIL" = "no" ]; then
                echo -e "\nError: Bluetooth hardware not available."
                read -rsp "Press any key to continue..." -n 1
                continue
            fi
            echo -e "\nPowering ON bluetooth..."
            bluetoothctl power on >/dev/null 2>&1
            echo "[*] Scanning for devices... Please wait..."
            bluetoothctl scan on >/dev/null 2>&1 &
            SCAN_PID=$!
            sleep 5
            kill $SCAN_PID >/dev/null 2>&1
            bluetoothctl scan off >/dev/null 2>&1
            echo -e "\nDevices found:"
            mapfile -t LDVC < <(bluetoothctl devices | grep -E '[0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2}){5}' | awk '{print $2, substr($0, index($0,$3))}')
            if [ ${#LDVC[@]} -eq 0 ]; then
                echo "[!] No devices found."
                read -rsp "Press any key to continue..." -n 1
            else
                for i in "${!LDVC[@]}"; do
                    echo "[$i] ${LDVC[$i]}"
                done
                read -p "Select device number to pair & connect: " DEV_IDX
                if [[ -n "$DEV_IDX" && "$DEV_IDX" =~ ^[0-9]+$ && $DEV_IDX -lt ${#LDVC[@]} ]]; then
                    SEL_MAC=$(echo "${LDVC[$DEV_IDX]}" | awk '{print $1}')
                    SEL_NM=$(echo "${LDVC[$DEV_IDX]}" | cut -d' ' -f2-)
                    echo -e "\nConnecting to: $SEL_NM ($SEL_MAC)"
                    bluetoothctl pair "$SEL_MAC"
                    bluetoothctl trust "$SEL_MAC"
                    bluetoothctl connect "$SEL_MAC"
                    read -rsp "Press any key to continue..." -n 1
                else
                    echo -e "\nInvalid choice!"
                    read -rsp "Press any key to continue..." -n 1
                fi
            fi
            ;;
        0)
            echo ""
            exit 0
            ;;
        *)
            echo -e "\nInvalid choice!"
            read -rsp "Press any key to continue..." -n 1
            ;;
    esac
done
