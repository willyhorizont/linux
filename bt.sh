#!/bin/bash

CMD_CLICK="lxterminal --geometry=88x28 --working-directory=$HOME -e $HOME/willyhorizont.github.io/linux/bt.sh"

declare -A ALL_MODES
ALL_MODES=(
    ["tint2"]="tint2"
    ["xfce4-panel"]="xfce4-panel"
)

IS_INDICATOR=false
MODE="${ALL_MODES["tint2"]}"
GENMON_ID=""
IC_INIT="⏳"
IC_ON="🔵"
IC_OFF="🚫"
IC_NONE="❌"

PREF=" "
SUFF=" "
USE_PANGO=false
USE_DARK=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --indicator)   IS_INDICATOR=true; shift ;;
        --mode)
            if [[ -n "$2" && -n "${ALL_MODES["$2"]}" ]]; then
                MODE="${ALL_MODES["$2"]}"
            fi
            shift 2
            ;;
        --genmon-id)   GENMON_ID="$2";    shift 2 ;;
        --ic-init)     IC_INIT="$2";      shift 2 ;;
        --ic-on)       IC_ON="$2";        shift 2 ;;
        --ic-off)      IC_OFF="$2";       shift 2 ;;
        --ic-none)     IC_NONE="$2";      shift 2 ;;
        --pref)        PREF="$2";         shift 2 ;;
        --suff)        SUFF="$2";         shift 2 ;;
        --pango)       USE_PANGO=true;    shift ;;
        --dark)        USE_DARK=true;     shift ;;
        *)                                shift ;;
    esac
done

get_bt_stat() {
    DVC_NM="None"
    if [ -z "$(ls /sys/class/bluetooth/ 2>/dev/null)" ]; then
        STATE="NONE"
    elif rfkill list bluetooth | grep -q "Soft blocked: yes"; then
        STATE="OFF"
    else
        CONN_DIR=$(ls -d /sys/class/bluetooth/hci0/dev_* 2>/dev/null | head -n1)
        if [ -z "$CONN_DIR" ]; then
            STATE="INIT"
            DVC_NM="Not Connected"
        else
            STATE="ON"
            local conn_mac
            conn_mac=$(basename "$CONN_DIR" | sed 's/dev_//; s/_/:/g')
            local dvc_full_nm
            dvc_full_nm=$(bluetoothctl info "$conn_mac" 2>/dev/null | awk -F': ' '/Name:/ {print $2}')
            DVC_NM=${dvc_full_nm:-Unknown}
        fi
    fi
}

print_indicator() {
    get_bt_stat
    local dvc_nm=""
    local ic_cur=""
    case "$STATE" in
        NONE) ic_cur="$IC_NONE" ;;
        OFF)  ic_cur="$IC_OFF" ;;
        INIT) ic_cur="$IC_INIT" ;;
        ON)
            ic_cur="$IC_ON"
            dvc_nm="${DVC_NM}"
            ;;
    esac

    local out_txt=""
    if $USE_PANGO; then
        if $USE_DARK; then
            out_txt="${out_txt}<span background='#000000' foreground='#00ADD8'>${PREF}</span>"
            out_txt="${out_txt}<span background='#000000' foreground='#FF1493'>BT </span>"
            out_txt="${out_txt}<span background='#000000' foreground='#CCFF00'>${ic_cur}</span>"
            out_txt="${out_txt}<span background='#000000' foreground='#00ADD8'>${SUFF}</span>"
        else
            out_txt="${out_txt}<span background='#FFFFFF' foreground='#000000'>${PREF}</span>"
            out_txt="${out_txt}<span background='#FFFFFF' foreground='#000000'>BT </span>"
            out_txt="${out_txt}<span background='#FFFFFF' foreground='#000000'>${ic_cur}</span>"
            out_txt="${out_txt}<span background='#FFFFFF' foreground='#000000'>${SUFF}</span>"
        fi
    else
        out_txt="${PREF}BT=${ic_cur}${SUFF}"
    fi

    local tooltip_txt
    tooltip_txt=$(cat << EOF
bt.sh
--ic-init = ${IC_INIT}
--ic-on   = ${IC_ON}
--ic-off  = ${IC_OFF}
--ic-none = ${IC_NONE}
click to open bt.sh
${dvc_nm}
EOF
    )
    if [ "$MODE" = "${ALL_MODES["xfce4-panel"]}" ]; then
        echo "<txt>${out_txt}</txt>"
        echo "<txtclick>$CMD_CLICK</txtclick>"
        echo "<tool>$tooltip_txt</tool>"
    else
        echo "${out_txt}"
        printf "\e[2J%s\n" "$tooltip_txt" 1>&2
    fi
}

if $IS_INDICATOR; then
    print_indicator
    if [ "$MODE" = "${ALL_MODES["xfce4-panel"]}" ]; then
        [ -z "$GENMON_ID" ] && exit 0
        pgrep -f ".*dbus-monitor.*bluez.*xfce4-panel.*--plugin-event.*:refresh:bool:true.*" >/dev/null && exit 0
        setsid -f bash -c 'dbus-monitor --system "sender=org.bluez" 2>/dev/null | while read -r ln; do [[ "$ln" == *"PropertiesChanged"* || "$ln" == *"InterfacesAdded"* || "$ln" == *"InterfacesRemoved"* ]] && pgrep -x "xfce4-panel" >/dev/null && xfce4-panel --plugin-event="$1:refresh:bool:true" >/dev/null 2>&1; done' _ "$GENMON_ID" >/dev/null 2>&1
        exit 0
    fi
    dbus-monitor --system "sender=org.bluez" 2>/dev/null | while read -r ln; do
        if [[ "$ln" == *"PropertiesChanged"* || "$ln" == *"InterfacesAdded"* || "$ln" == *"InterfacesRemoved"* ]]; then
            print_indicator
        fi
    done
    exit 0
fi

while true; do
    clear
    echo "bt.sh"
    get_bt_stat
    case "$STATE" in
        NONE)
            echo "Hardware Status  : [ ${IC_NONE} Not Found / Disabled ]"
            echo "Connected Device : [ ${DVC_NM} ]"
            HW_AVAIL="no"
            ;;
        OFF)
            echo "Hardware Status  : [ ${IC_OFF} OFF ]"
            echo "Connected Device : [ ${DVC_NM} ]"
            HW_AVAIL="yes"
            ;;
        INIT)
            echo "Hardware Status  : [ ${IC_ON} ON ]"
            echo "Connected Device : [ ${DVC_NM} ]"
            HW_AVAIL="yes"
            ;;
        ON)
            echo "Hardware Status  : [ ${IC_ON} ON ]"
            echo "Connected Device : [ ${DVC_NM} ]"
            HW_AVAIL="yes"
            ;;
    esac
    echo "1) Open interactive bluetoothctl bluez wizard"
    echo "q) Exit"
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
        [qQ])
            echo ""
            exit 0
            ;;
        *)
            echo -e "\nInvalid choice!"
            read -rsp "Press any key to continue..." -n 1
            ;;
    esac
done
