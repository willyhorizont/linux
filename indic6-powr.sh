#!/bin/bash

IC_INIT="⏳"
BAT_ON_HI="🔋"
BAT_ON_LO="🪫"
BAT_ON="🔋"
BAT_NONE="❌"
AC_ON="🔌"
AC_NONE="❌️"

HAS_BAT_HI=false
HAS_BAT_LO=false
HAS_BAT_ON=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --ic-init)    IC_INIT="$2";    shift 2 ;;
        --bat-on-hi)  BAT_ON_HI="$2";  HAS_BAT_HI=true; shift 2 ;;
        --bat-on-lo)  BAT_ON_LO="$2";  HAS_BAT_LO=true; shift 2 ;;
        --bat-on)     BAT_ON="$2";     HAS_BAT_ON=true; shift 2 ;;
        --bat-none)   BAT_NONE="$2";   shift 2 ;;
        --ac-on)      AC_ON="$2";      shift 2 ;;
        --ac-none)     AC_NONE="$2";    shift 2 ;;
        *) shift ;;
    esac
done

TOOLTIP_TXT=$(cat << EOF
\`                                 
        💡 indic6-powr.sh          
                                   
    --ic-init    ; ${IC_INIT}      
    --bat-on-hi  ; ${BAT_ON_HI}    
    --bat-on-lo  ; ${BAT_ON_LO}    
    --bat-on     ; ${BAT_ON}       
    --bat-none   ; ${BAT_NONE}     
    --ac-on      ; ${AC_ON}        
    --ac-none    ; ${AC_NONE}      
                                   
      click to open tui6-powr.sh   
                                  .
EOF
)

if [ ! -d /sys/class/power_supply ] || [ -z "$(ls /sys/class/power_supply/ | grep -E '^BAT|^battery')" ]; then
    # "BAT=X   0% | AC=Y |"
    echo "BAT=${BAT_NONE}   0% | AC=${AC_ON} |"
    printf "%s" "$TOOLTIP_TXT" 1>&2
    exit 0
fi

TOT_CHARGE=0
TOT_FULL=0

for bat in /sys/class/power_supply/BAT*; do
    if [ -f "$bat/energy_now" ] && [ -f "$bat/energy_full" ]; then
        NOW=$(cat "$bat/energy_now")
        FULL=$(cat "$bat/energy_full")
        TOT_CHARGE=$((TOT_CHARGE + NOW))
        TOT_FULL=$((TOT_FULL + FULL))
    elif [ -f "$bat/charge_now" ] && [ -f "$bat/charge_full" ]; then
        NOW=$(cat "$bat/charge_now")
        FULL=$(cat "$bat/charge_full")
        TOT_CHARGE=$((TOT_CHARGE + NOW))
        TOT_FULL=$((TOT_FULL + FULL))
    fi
done

if [ "$TOT_FULL" -gt 0 ]; then
    CAP=$(( TOT_CHARGE * 100 / TOT_FULL ))
else
    CAP=0
fi

CAP_PAD=$(printf "%3d" "$CAP")

ACPI_OUT=$(acpi -b 2>/dev/null)

get_bat_icon() {
    if $HAS_BAT_HI && $HAS_BAT_LO; then
        if [ "$CAP" -ge 50 ]; then echo "$BAT_ON_HI"; else echo "$BAT_ON_LO"; fi
    elif $HAS_BAT_ON; then
        echo "$BAT_ON"
    else
        if [ "$CAP" -ge 50 ]; then echo "$BAT_ON_HI"; else echo "$BAT_ON_LO"; fi
    fi
}

if [[ "$ACPI_OUT" =~ "Charging" ]] || [[ "$ACPI_OUT" =~ "Full" ]] || [[ "$ACPI_OUT" =~ "Not charging" ]]; then
    SEL_BAT_ON=$(get_bat_icon)
    # "BAT=Y 100% | AC=Y |"
    echo "BAT=${SEL_BAT_ON} ${CAP_PAD}% | AC=${AC_ON} |"
    printf "%s" "$TOOLTIP_TXT" 1>&2
else
    if [ -f /sys/class/power_supply/AC/online ] && [ "$(cat /sys/class/power_supply/AC/online)" = "0" ]; then
        SEL_BAT_ON=$(get_bat_icon)
        if [ "$CAP" -lt 40 ]; then
            notify-send "⚠️ Low BAT"
        fi
        # "BAT=Y 100% | AC=N |"
        echo "BAT=${SEL_BAT_ON} ${CAP_PAD}% | AC=${AC_NONE} |"
        printf "%s" "$TOOLTIP_TXT" 1>&2
    else
        # "BAT=? 100% | AC=? |"
        echo "BAT=${IC_INIT} ${CAP_PAD}% | AC=${IC_INIT} |"
        printf "%s" "$TOOLTIP_TXT" 1>&2
    fi
fi
