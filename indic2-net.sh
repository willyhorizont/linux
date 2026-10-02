#!/bin/bash

IC_INIT="🌐"
IC_WIFI="🛜"
IC_ETH="🔌"
IC_NONE="✈️"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --ic-init)  IC_INIT="$2";  shift 2 ;;
        --ic-wifi)    IC_WIFI="$2";  shift 2 ;;
        --ic-eth)   IC_ETH="$2";   shift 2 ;;
        --ic-none)  IC_NONE="$2";  shift 2 ;;
        *) shift ;;
    esac
done

TOOLTIP_TXT=$(cat << EOF
\`                               
       💡 indic2-net.sh          
                                 
     --ic-init  ; ${IC_INIT}     
     --ic-wifi  ; ${IC_WIFI}     
     --ic-eth   ; ${IC_ETH}      
     --ic-none  ; ${IC_NONE}     
                                 
    click to open tui2-net.sh    
                                .
EOF
)

if [ -z "$(ls /sys/class/net/ 2>/dev/null | grep -E 'eth|wlan|enp|wlp')" ]; then
    # "NET=🌐   0% | "
    echo "NET=${IC_INIT}   0% | "
    printf "%s" "$TOOLTIP_TXT" 1>&2
    exit 0
fi

CON_TYPE=$(nmcli -t -f TYPE,STATE dev | awk -F: '$2=="connected" {print $1; exit}')

if [ "$CON_TYPE" = "ethernet" ]; then
    # "NET=🔌 100% | "
    echo "NET=${IC_ETH} 100% | "
    printf "%s" "$TOOLTIP_TXT" 1>&2
elif [ "$CON_TYPE" = "wifi" ]; then
    SIG=$(nmcli -t -f active,ssid,signal dev wifi | awk -F: '/^yes:/ {print $3}')
    SIG_PAD=$(printf "%3d" "${SIG:-0}")
    # "NET=🛜 100% | "
    echo "NET=${IC_WIFI} ${SIG_PAD}% | "
    printf "%s" "$TOOLTIP_TXT" 1>&2
else
    if [ "$(nmcli radio wifi)" = "disabled" ]; then
        # "NET=✈️   0% | "
        echo "NET=${IC_NONE}   0% | "
        printf "%s" "$TOOLTIP_TXT" 1>&2
    else
        # "NET=🌐   0% | "
        echo "NET=${IC_INIT}   0% | "
        printf "%s" "$TOOLTIP_TXT" 1>&2
    fi
fi
