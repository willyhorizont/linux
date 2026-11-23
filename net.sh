#!/bin/bash

IS_INDICATOR=false
IC_INIT="🌐"
IC_WIFI="🛜"
IC_ETH="🔌"
IC_NONE="✈️"

PREF=" "
SUFF=" "

while [[ $# -gt 0 ]]; do
    case "$1" in
        --indicator)   IS_INDICATOR=true;  shift ;;
        --ic-init)     IC_INIT="$2";       shift 2 ;;
        --ic-wifi)     IC_WIFI="$2";       shift 2 ;;
        --ic-eth)      IC_ETH="$2";        shift 2 ;;
        --ic-none)     IC_NONE="$2";       shift 2 ;;
        --pref)        PREF="$2";          shift 2 ;;
        --suff)        SUFF="$2";          shift 2 ;;
        *)                                 shift ;;
    esac
done

print_indicator() {
    local tooltip_txt_base
    tooltip_txt_base=$(cat << EOF
net.sh
--ic-init = ${IC_INIT}
--ic-wifi = ${IC_WIFI}
--ic-eth  = ${IC_ETH}
--ic-none = ${IC_NONE}
click to open net.sh
EOF
    )
    local tooltip_txt
    if [ -z "$(ls /sys/class/net/ 2>/dev/null | grep -E 'eth|wlan|enp|wlp')" ]; then
        tooltip_txt=$(cat << EOF
${tooltip_txt_base}
${IC_INIT}
EOF
        )
        echo "${PREF}NET=${IC_INIT}   0%${SUFF}"
        printf "\e[2J%s\n" "$tooltip_txt" 1>&2
        return 0
    fi
    local con_type
    con_type=$(nmcli -t -f TYPE,STATE dev | awk -F: '$2=="connected" {print $1; exit}')
    if [ "$con_type" = "ethernet" ]; then
        tooltip_txt=$(cat << EOF
${tooltip_txt_base}
${IC_ETH}
EOF
        )
        echo "${PREF}NET=${IC_ETH} 100%${SUFF}"
        printf "\e[2J%s\n" "$tooltip_txt" 1>&2
    elif [ "$con_type" = "wifi" ]; then
        local wifi_info
        local ssid
        local sig
        local sig_pad
        wifi_info=$(nmcli -t -f active,ssid,signal dev wifi | awk -F: '/^yes:/ {print $2 "," $3}')
        ssid=${wifi_info%,*}
        sig=${wifi_info#*,}
        sig_pad=$(printf "%3d" "${sig:-0}")
        tooltip_txt=$(cat << EOF
${tooltip_txt_base}
${IC_WIFI} ${ssid:-Unknown}
EOF
        )
        echo "${PREF}NET=${IC_WIFI} ${sig_pad}%${SUFF}"
        printf "\e[2J%s\n" "$tooltip_txt" 1>&2
    else
        if [ "$(nmcli radio wifi)" = "disabled" ]; then
            tooltip_txt=$(cat << EOF
${tooltip_txt_base}
${IC_NONE}
EOF
            )
            echo "${PREF}NET=${IC_NONE}   0%${SUFF}"
            printf "\e[2J%s\n" "$tooltip_txt" 1>&2
        else
            tooltip_txt=$(cat << EOF
${tooltip_txt_base}
${IC_INIT}
EOF
            )
            echo "${PREF}NET=${IC_INIT}   0%${SUFF}"
            printf "\e[2J%s\n" "$tooltip_txt" 1>&2
        fi
    fi
}

if ! $IS_INDICATOR; then
    nmtui
    exit 0
fi

print_indicator
nmcli monitor | while read -r _; do
    print_indicator
done
