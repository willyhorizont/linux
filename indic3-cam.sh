#!/bin/bash

IC_INIT="⏳"
IC_ON="👁️"
IC_STB="⚠️"
IC_NONE="🚫"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --ic-init)  IC_INIT="$2";  shift 2 ;;
        --ic-on)    IC_ON="$2";    shift 2 ;;
        --ic-standby)   IC_STB="$2";   shift 2 ;;
        --ic-none)  IC_NONE="$2";  shift 2 ;;
        *) shift ;;
    esac
done

TOOLTIP_TXT=$(cat << EOF
\`                               
         💡 indic3-cam.sh        
                                 
    --ic-init     ; ${IC_INIT}   
    --ic-on       ; ${IC_ON}     
    --ic-standby  ; ${IC_STB}    
    --ic-none     ; ${IC_NONE}   
                                 
     click to open tui3-cam.sh   
                                .
EOF
)

STATUS_FILE="/sys/class/video4linux/video0/device/power/runtime_status"

if [ ! -f "$STATUS_FILE" ]; then
    # "CAM=X | "
    echo "CAM=${IC_NONE} | "
    printf "%s" "$TOOLTIP_TXT" 1>&2
else
    read -r STATUS < "$STATUS_FILE"
    if [ "$STATUS" = "active" ]; then
        # "CAM=Y | "
        echo "CAM=${IC_ON} | "
        printf "%s" "$TOOLTIP_TXT" 1>&2
    elif [ "$STATUS" = "suspended" ] || [ "$STATUS" = "unsupported" ]; then
        # "CAM=N | "
        echo "CAM=${IC_STB} | "
        printf "%s" "$TOOLTIP_TXT" 1>&2
    else
        # "CAM=? | "
        echo "CAM=${IC_INIT} | "
        printf "%s" "$TOOLTIP_TXT" 1>&2
    fi
fi
