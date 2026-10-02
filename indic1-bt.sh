#!/bin/bash

IC_INIT="⏳"
IC_ON="🔵"
IC_OFF="🚫"
IC_NONE="❌"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --ic-init)  IC_INIT="$2";  shift 2 ;;
        --ic-on)    IC_ON="$2";    shift 2 ;;
        --ic-off)   IC_OFF="$2";   shift 2 ;;
        --ic-none)  IC_NONE="$2";  shift 2 ;;
        *) shift ;;
    esac
done

TOOLTIP_TXT=$(cat << EOF
\`                             
      💡 indic1-bt.sh          
                               
    --ic-init  ; ${IC_INIT}    
    --ic-on    ; ${IC_ON}      
    --ic-off   ; ${IC_OFF}     
    --ic-none  ; ${IC_NONE}    
                               
    click to open tui1-bt.sh   
                              .
EOF
)

if [ -z "$(ls /sys/class/bluetooth/ 2>/dev/null)" ]; then
    # " BT=X | "
    echo " BT=${IC_NONE} | "
    printf "%s" "$TOOLTIP_TXT" 1>&2
elif rfkill list bluetooth | grep -q "Soft blocked: yes"; then
    # " BT=N | "
    echo " BT=${IC_OFF} | "
    printf "%s" "$TOOLTIP_TXT" 1>&2
else
    if ls /sys/class/bluetooth/hci0/dev_* >/dev/null 2>&1; then
        # " BT=Y | "
        echo " BT=${IC_ON} | "
        printf "%s" "$TOOLTIP_TXT" 1>&2
    else
        # " BT=? | "
        echo " BT=${IC_INIT} | "
        printf "%s" "$TOOLTIP_TXT" 1>&2
    fi
fi
