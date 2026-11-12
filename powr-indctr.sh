#!/bin/bash

IC_INIT="⏳"
BAT_ON_HI="🔋"
BAT_ON_LO="🪫"
BAT_ON="🔋"
BAT_NONE="❌"
AC_ON="🔌"
AC_NONE="❌️"

PREF=" "
SUFF=" "
SEP=" | "

HAS_BAT_HI=false
HAS_BAT_LO=false
HAS_BAT_ON=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --ic-init)    IC_INIT="$2";                      shift 2 ;;
        --bat-on-hi)  BAT_ON_HI="$2";  HAS_BAT_HI=true;  shift 2 ;;
        --bat-on-lo)  BAT_ON_LO="$2";  HAS_BAT_LO=true;  shift 2 ;;
        --bat-on)     BAT_ON="$2";     HAS_BAT_ON=true;  shift 2 ;;
        --bat-none)   BAT_NONE="$2";                     shift 2 ;;
        --ac-on)      AC_ON="$2";                        shift 2 ;;
        --ac-none)    AC_NONE="$2";                      shift 2 ;;
        --pref)       PREF="$2";                         shift 2 ;;
        --suff)       SUFF="$2";                         shift 2 ;;
        --sep)        SEP="$2";                          shift 2 ;;
        *)                                               shift ;;
    esac
done

TOOLTIP_TXT=$(cat << EOF
powr-indctr.sh
--ic-init   = ${IC_INIT}      
--bat-on-hi = ${BAT_ON_HI}    
--bat-on-lo = ${BAT_ON_LO}    
--bat-on    = ${BAT_ON}       
--bat-none  = ${BAT_NONE}     
--ac-on     = ${AC_ON}        
--ac-none   = ${AC_NONE}      
click to open powr-mgr.sh
EOF
)

if [ ! -d /sys/class/power_supply ] || [ -z "$(ls /sys/class/power_supply/ | grep -E '^BAT|^battery')" ]; then
    echo "${PREF}BAT=${BAT_NONE}   0%${SEP}AC=${AC_ON}${SUFF}"
    printf "%s" "$TOOLTIP_TXT" 1>&2
    exit 0
fi

TOT_CHARGE=0
TOT_FULL=0
IS_CHARGING=false

for bat in /sys/class/power_supply/BAT*; do
    [ -e "$bat" ] || continue
    if [ -f "$bat" ]; then
        STATUS_VAL=$(cat "$bat")
        if [ "$STATUS_VAL" = "Charging" ]; then
            IS_CHARGING=true
        fi
    fi
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

get_bat_icon() {
    if $HAS_BAT_HI && $HAS_BAT_LO; then
        if [ "$CAP" -ge 50 ]; then echo "$BAT_ON_HI"; else echo "$BAT_ON_LO"; fi
    elif $HAS_BAT_ON; then
        echo "$BAT_ON"
    else
        if [ "$CAP" -ge 50 ]; then echo "$BAT_ON_HI"; else echo "$BAT_ON_LO"; fi
    fi
}

AC_ONLINE=0
[ -f /sys/class/power_supply/AC/online ] && AC_ONLINE=$(cat /sys/class/power_supply/AC/online)

if $IS_CHARGING || [ "$AC_ONLINE" = "1" ]; then
    echo "${PREF}BAT=${BAT_ON} ${CAP_PAD}%${SEP}AC=${AC_ON}${SUFF}"
    printf "%s" "$TOOLTIP_TXT" 1>&2
else
    if [ "$AC_ONLINE" = "0" ]; then
        SEL_BAT_ON=$(get_bat_icon)
        if [ "$CAP" -lt 40 ]; then
            notify-send "⚠️ Low BAT"
        fi
        echo "${PREF}BAT=${SEL_BAT_ON} ${CAP_PAD}%${SEP}AC=${AC_NONE}${SUFF}"
        printf "%s" "$TOOLTIP_TXT" 1>&2
    else
        echo "${PREF}BAT=${IC_INIT} ${CAP_PAD}%${SEP}AC=${IC_INIT}${SUFF}"
        printf "%s" "$TOOLTIP_TXT" 1>&2
    fi
fi
