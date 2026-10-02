#!/bin/bash

IC_INIT="⏳"
IC_ON="🚨"
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
      💡 indic5-vol.sh          
                                
    --ic-init  ; ${IC_INIT}     
    --ic-on    ; ${IC_ON}       
    --ic-off   ; ${IC_OFF}      
    --ic-none  ; ${IC_NONE}     
                                
    click to open tui5-vol.sh   
                               .
EOF
)

VOL=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk '{print $5}' | tr -d '%')

if [ -z "$VOL" ]; then
    # "VOL=X   0% | "
    echo "VOL=${IC_NONE}   0% | "
    printf "%s" "$TOOLTIP_TXT" 1>&2
    exit 0
fi

VOL_PAD=$(printf "%3d" "${VOL:-0}")

if [ "$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}')" = "yes" ]; then
    # "VOL=N 100% | "
    echo "VOL=${IC_OFF} ${VOL_PAD}% | "
    printf "%s" "$TOOLTIP_TXT" 1>&2
else
    # "VOL=Y 100% | "
    echo "VOL=${IC_ON} ${VOL_PAD}% | "
    printf "%s" "$TOOLTIP_TXT" 1>&2
fi
