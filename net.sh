#!/bin/bash

CMD_CLICK="lxterminal --geometry=88x28 --working-directory=$HOME -e $HOME/willyhorizont.github.io/linux/net.sh"

declare -A ALL_MODES
ALL_MODES=(
    ["tint2"]="tint2"
    ["xfce4-panel"]="xfce4-panel"
)

IS_INDICATOR=false
MODE="${ALL_MODES["tint2"]}"
GENMON_ID=""
IC_INIT="🌐"
IC_WIFI="🛜"
IC_ETH="🔌"
IC_NONE="✈️"

PREF=" "
SUFF=" "
USE_PANGO=false
USE_DARK=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --indicator)   IS_INDICATOR=true;  shift ;;
        --mode)
            if [[ -n "$2" && -n "${ALL_MODES["$2"]}" ]]; then
                MODE="${ALL_MODES["$2"]}"
            fi
            shift 2
            ;;
        --genmon-id)   GENMON_ID="$2";     shift 2 ;;
        --ic-init)     IC_INIT="$2";       shift 2 ;;
        --ic-wifi)     IC_WIFI="$2";       shift 2 ;;
        --ic-eth)      IC_ETH="$2";        shift 2 ;;
        --ic-none)     IC_NONE="$2";       shift 2 ;;
        --pref)        PREF="$2";          shift 2 ;;
        --suff)        SUFF="$2";          shift 2 ;;
        --pango)       USE_PANGO=true;     shift ;;
        --dark)        USE_DARK=true;      shift ;;
        *)                                 shift ;;
    esac
done

OUT_TXT=""

format_out() {
    local icon="$1"
    local val="$2"
    if $USE_PANGO; then
        if $USE_DARK; then
            OUT_TXT="${OUT_TXT}<span background='#000000' foreground='#00ADD8'>${PREF}</span>"
            OUT_TXT="${OUT_TXT}<span background='#000000' foreground='#FF1493'>NET </span>"
            OUT_TXT="${OUT_TXT}<span background='#000000' foreground='#CCFF00'>${icon} ${val}</span>"
            OUT_TXT="${OUT_TXT}<span background='#000000' foreground='#FF1493'>%</span>"
            OUT_TXT="${OUT_TXT}<span background='#000000' foreground='#00ADD8'>${SUFF}</span>"
        else
            OUT_TXT="${OUT_TXT}<span background='#FFFFFF' foreground='#000000'>${PREF}</span>"
            OUT_TXT="${OUT_TXT}<span background='#FFFFFF' foreground='#000000'>NET </span>"
            OUT_TXT="${OUT_TXT}<span background='#FFFFFF' foreground='#000000'>${icon} ${val}</span>"
            OUT_TXT="${OUT_TXT}<span background='#FFFFFF' foreground='#000000'>%</span>"
            OUT_TXT="${OUT_TXT}<span background='#FFFFFF' foreground='#000000'>${SUFF}</span>"
        fi
    else
        OUT_TXT="${PREF}NET=${icon} ${val}%${SUFF}"
    fi
}

get_net_stat() {
    DVC_INFO=""
    if [ -z "$(ls /sys/class/net/ 2>/dev/null | grep -E 'eth|wlan|enp|wlp')" ]; then
        STATE="INIT"
        format_out "${IC_INIT}" "  0"
        DVC_INFO="${IC_INIT}"
        return 0
    fi
    local con_type
    con_type=$(nmcli -t -f TYPE,STATE dev | awk -F: '$2=="connected" {print $1; exit}')
    if [ "$con_type" = "ethernet" ]; then
        STATE="ETH"
        format_out "${IC_ETH}" "100"
        DVC_INFO="${IC_ETH}"
    elif [ "$con_type" = "wifi" ]; then
        local wifi_info
        local ssid
        local sig
        local sig_pad
        wifi_info=$(nmcli -t -f active,ssid,signal dev wifi | awk -F: '/^yes:/ {print $2 "," $3}')
        ssid=${wifi_info%,*}
        sig=${wifi_info#*,}
        sig_pad=$(printf "%3d" "${sig:-0}")
        STATE="WIFI"
        format_out "${IC_WIFI}" "${sig_pad}"
        DVC_INFO="${IC_WIFI} ${ssid:-Unknown}"
    elif [ "$(nmcli radio wifi)" = "disabled" ]; then
        STATE="NONE"
        format_out "${IC_NONE}" "  0"
        DVC_INFO="${IC_NONE}"
    else
        STATE="INIT"
        format_out "${IC_INIT}" "  0"
        DVC_INFO="${IC_INIT}"
    fi
}

print_indicator() {
    get_net_stat
    local tooltip_txt
    tooltip_txt=$(cat << EOF
net.sh
--ic-init = ${IC_INIT}
--ic-wifi = ${IC_WIFI}
--ic-eth  = ${IC_ETH}
--ic-none = ${IC_NONE}
click to open net.sh
${DVC_INFO}
EOF
    )
    if [ "$MODE" = "${ALL_MODES["xfce4-panel"]}" ]; then
        echo "<txt>${OUT_TXT}</txt>"
        echo "<txtclick>$CMD_CLICK</txtclick>"
        echo "<tool>$tooltip_txt</tool>"
    else
        echo "${OUT_TXT}"
        printf "\e[2J%s\n" "$tooltip_txt" 1>&2
    fi
}

if $IS_INDICATOR; then
    print_indicator
    if [ "$MODE" = "${ALL_MODES["xfce4-panel"]}" ]; then
        [ -z "$GENMON_ID" ] && exit 0
        pgrep -f ".*nmcli monitor.*xfce4-panel.*--plugin-event.*:refresh:bool:true.*" >/dev/null && exit 0
        setsid -f bash -c 'nmcli monitor 2>/dev/null | while read -r _; do pgrep -x "xfce4-panel" >/dev/null && xfce4-panel --plugin-event="$1:refresh:bool:true" >/dev/null 2>&1; done' _ "$GENMON_ID" >/dev/null 2>&1
        exit 0
    fi
    nmcli monitor 2>/dev/null | while read -r _; do
        print_indicator
    done
    exit 0
fi

nmtui
exit 0
