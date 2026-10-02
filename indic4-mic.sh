#!/bin/bash

IC_ON="👂"
IC_OFF="🚫"
IC_NONE="❌"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --ic-on)    IC_ON="$2";    shift 2 ;;
        --ic-off)   IC_OFF="$2";   shift 2 ;;
        --ic-none)  IC_NONE="$2";  shift 2 ;;
        *) shift ;;
    esac
done

TOOLTIP_TXT=$(cat << EOF
\`                                
       💡 indic4-mic.sh           
                                  
     --ic-on    ; ${IC_ON}        
     --ic-off   ; ${IC_OFF}       
     --ic-none  ; ${IC_NONE}      
                                  
     click to open tui4-mic.sh    
                                 .
EOF
)

MIC_VOL=$(pactl get-source-volume @DEFAULT_SOURCE@ 2>/dev/null | awk '{print $5}' | tr -d '%')

if [ -z "$MIC_VOL" ]; then
    # "MIC=X   0% | "
    echo "MIC=${IC_NONE}   0% | "
    printf "%s" "$TOOLTIP_TXT" 1>&2
    exit 0
fi

MIC_PAD=$(printf "%3d" "${MIC_VOL:-0}")

if [ "$(pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | awk '{print $2}')" = "yes" ]; then
    # "MIC=N 100% | "
    echo "MIC=${IC_OFF} ${MIC_PAD}% | "
    printf "%s" "$TOOLTIP_TXT" 1>&2
else
    # "MIC=Y 100% | "
    echo "MIC=${IC_ON} ${MIC_PAD}% | "
    printf "%s" "$TOOLTIP_TXT" 1>&2
fi
