#!/bin/bash

IC_INIT="🌐"
IC_WIFI="🛜"
IC_ETH="🔌"
IC_NONE="✈️"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --ic-init)  IC_INIT="$2";  shift 2 ;;
        --ic-wifi)  IC_WIFI="$2";  shift 2 ;;
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
    TOOLTIP_TXT=$(cat << EOF
\`                               
       💡 indic2-net.sh          
                                 
    ${IC_INIT}   0%              
                                 
     --ic-init  ; ${IC_INIT}     
     --ic-wifi  ; ${IC_WIFI}     
     --ic-eth   ; ${IC_ETH}      
     --ic-none  ; ${IC_NONE}     
                                 
    click to open tui2-net.sh    
                                .
EOF
    )
    # "NET=🌐   0% | "
    echo "NET=${IC_INIT}   0% | "
    printf "%s" "$TOOLTIP_TXT" 1>&2
    exit 0
fi

CON_TYPE=$(nmcli -t -f TYPE,STATE dev | awk -F: '$2=="connected" {print $1; exit}')

if [ "$CON_TYPE" = "ethernet" ]; then
    TOOLTIP_TXT=$(cat << EOF
\`                               
       💡 indic2-net.sh          
                                 
    ${IC_ETH} 100%               
                                 
     --ic-init  ; ${IC_INIT}     
     --ic-wifi  ; ${IC_WIFI}     
     --ic-eth   ; ${IC_ETH}      
     --ic-none  ; ${IC_NONE}     
                                 
    click to open tui2-net.sh    
                                .
EOF
    )
    # "NET=🔌 100% | "
    echo "NET=${IC_ETH} 100% | "
    printf "%s" "$TOOLTIP_TXT" 1>&2
elif [ "$CON_TYPE" = "wifi" ]; then
    WIFI_INFO=$(nmcli -t -f active,ssid,signal dev wifi | awk -F: '/^yes:/ {print $2 "," $3}')
    SSID=${WIFI_INFO%,*}
    SIG=${WIFI_INFO#*,}
    SIG_PAD=$(printf "%3d" "${SIG:-0}")
    TOOLTIP_TXT=$(cat << EOF
\`                               
       💡 indic2-net.sh          
                                 
     ${IC_WIFI} ${SSID:-Unknown}                   
                                 
     --ic-init  ; ${IC_INIT}     
     --ic-wifi  ; ${IC_WIFI}     
     --ic-eth   ; ${IC_ETH}      
     --ic-none  ; ${IC_NONE}     
                                 
    click to open tui2-net.sh    
                                .
EOF
    )
    # "NET=🛜 100% | "
    echo "NET=${IC_WIFI} ${SIG_PAD}% | "
    printf "%s" "$TOOLTIP_TXT" 1>&2
else
    if [ "$(nmcli radio wifi)" = "disabled" ]; then
        TOOLTIP_TXT=$(cat << EOF
\`                               
       💡 indic2-net.sh          
                                 
    ${IC_NONE}   0%              
                                 
     --ic-init  ; ${IC_INIT}     
     --ic-wifi  ; ${IC_WIFI}     
     --ic-eth   ; ${IC_ETH}      
     --ic-none  ; ${IC_NONE}     
                                 
    click to open tui2-net.sh    
                                .
EOF
        )
        # "NET=✈️   0% | "
        echo "NET=${IC_NONE}   0% | "
        printf "%s" "$TOOLTIP_TXT" 1>&2
    else
        TOOLTIP_TXT=$(cat << EOF
\`                               
       💡 indic2-net.sh          
                                 
    ${IC_INIT}   0%              
                                 
     --ic-init  ; ${IC_INIT}     
     --ic-wifi  ; ${IC_WIFI}     
     --ic-eth   ; ${IC_ETH}      
     --ic-none  ; ${IC_NONE}     
                                 
    click to open tui2-net.sh    
                                .
EOF
        )
        # "NET=🌐   0% | "
        echo "NET=${IC_INIT}   0% | "
        printf "%s" "$TOOLTIP_TXT" 1>&2
    fi
fi
