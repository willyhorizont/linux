#!/bin/bash

IS_INDICATOR=false
IC_INIT="⏳"
IC_ON="👁️"
IC_STB="⚠️"
IC_NONE="🚫"

PREF=""
SUFF=" | "

STATUS_FILE="/sys/class/video4linux/video0/device/power/runtime_status"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --indicator)   IS_INDICATOR=true; shift ;;
        --ic-init)     IC_INIT="$2";      shift 2 ;;
        --ic-on)       IC_ON="$2";        shift 2 ;;
        --ic-standby)  IC_STB="$2";       shift 2 ;;
        --ic-none)     IC_NONE="$2";      shift 2 ;;
        --pref)        PREF="$2";         shift 2 ;;
        --suff)        SUFF="$2";         shift 2 ;;
        *)                                shift ;;
    esac
done

get_cam_stat() {
    APP_NAME="None"
    CAM_PID=""
    if [ ! -f "$STATUS_FILE" ]; then
        STATE="NONE"
    else
        read -r STATUS < "$STATUS_FILE"
        if [ "$STATUS" = "active" ]; then
            CAM_PID=$(lsof -t /dev/video0 2>/dev/null | head -n1)
            if [ -n "$CAM_PID" ]; then
                STATE="ON"
                local raw_name
                raw_name=$(ps -p "$CAM_PID" -o comm= 2>/dev/null)
                APP_NAME=${raw_name:-Unknown}
            else
                STATE="ACCESS"
                APP_NAME="Accessing..."
            fi
        elif [ "$STATUS" = "suspended" ] || [ "$STATUS" = "unsupported" ]; then
            STATE="STB"
        else
            STATE="INIT"
        fi
    fi
}

if $IS_INDICATOR; then
    get_cam_stat
    if [ "$STATE" = "ON" ]; then
        APP_LINE="${APP_NAME} (PID: ${CAM_PID})"
    elif [ "$STATE" = "ACCESS" ]; then
        APP_LINE="${APP_NAME}"
    else
        APP_LINE=""
    fi
    TOOLTIP_TXT=$(cat << EOF
 cam.sh
 --ic-init    = ${IC_INIT}
 --ic-on      = ${IC_ON}
 --ic-standby = ${IC_STB}
 --ic-none    = ${IC_NONE}
 click to open cam.sh;
 ${APP_LINE}
EOF
    )
    case "$STATE" in
        NONE)   echo "${PREF}CAM=${IC_NONE}${SUFF}" ;;
        STB)    echo "${PREF}CAM=${IC_STB}${SUFF}" ;;
        INIT)   echo "${PREF}CAM=${IC_INIT}${SUFF}" ;;
        ACCESS) echo "${PREF}CAM=${IC_INIT}${SUFF}" ;;
        ON)     echo "${PREF}CAM=${IC_ON}${SUFF}" ;;
    esac
    printf "%s" "$TOOLTIP_TXT" 1>&2
    exit 0
fi

while true; do
    clear
    echo "cam.sh"
    get_cam_stat
    case "$STATE" in
        NONE)
            echo "Hardware Status : [ ${IC_NONE} Disabled ]"
            echo "Active App      : [ ${APP_NAME} ]"
            HW_CONNECTED=false
            TOGGLE_TXT="1) Enable Camera Module"
            ;;
        STB)
            echo "Hardware Status : [ ${IC_STB}  Standby / Idle / Sleep ]"
            echo "Active App      : [ ${APP_NAME} ]"
            HW_CONNECTED=true
            TOGGLE_TXT="1) Disable Camera Module"
            ;;
        INIT)
            echo "Hardware Status : [ ${IC_INIT} Disabled ]"
            echo "Active App      : [ ${APP_NAME} ]"
            HW_CONNECTED=true
            TOGGLE_TXT="1) Disable Camera Module"
            ;;
        ACCESS)
            echo "Hardware Status : [ ${IC_ON}  ON / Active ]"
            echo "Active App      : [ ${IC_INIT} ${APP_NAME} ]"
            HW_CONNECTED=true
            TOGGLE_TXT="1) Disable Camera Module"
            ;;
        ON)
            echo "Hardware Status : [ ${IC_ON}  ON / Active ]"
            echo "Active App      : [ ${IC_ON}  ${APP_NAME} (PID: $CAM_PID) ]"
            HW_CONNECTED=true
            TOGGLE_TXT="1) Disable Camera Module"
            ;;
    esac
    echo "$TOGGLE_TXT"
    echo "0) Exit"
    echo -n "Select choice: "
    read -n 1 CHOICE
    case "$CHOICE" in
        1)
            if $HW_CONNECTED; then
                echo -e "\nDisabling camera hardware module..."
                if sudo modprobe -r uvcvideo 2>/dev/null; then
                    echo "Camera successfully turned OFF."
                else
                    echo "Failed! Camera busy or invalid password."
                fi
            else
                echo -e "\nEnabling camera hardware module..."
                if sudo modprobe uvcvideo 2>/dev/null; then
                    echo "Camera successfully turned ON."
                else
                    echo "Failed! Could not load uvcvideo kernel driver or invalid password."
                fi
            fi
            read -rsp "Press any key to continue..." -n 1
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
