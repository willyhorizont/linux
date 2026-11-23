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

IS_NOTIFIED=false

get_bat_icon() {
    local cap="$1"
    if $HAS_BAT_HI && $HAS_BAT_LO; then
        if [ "$cap" -ge 50 ]; then echo "$BAT_ON_HI"; else echo "$BAT_ON_LO"; fi
    elif $HAS_BAT_ON; then
        echo "$BAT_ON"
    else
        if [ "$cap" -ge 50 ]; then echo "$BAT_ON_HI"; else echo "$BAT_ON_LO"; fi
    fi
}

print_status() {
    local scrn_brghtnss
    scrn_brghtnss=$("$HOME/willyhorizont.github.io/linux/scrn-brghtnss-mgr.sh" --print)
    
    local tooltip_txt
    tooltip_txt=$(cat << EOF
powr-indctr.sh
Screen Brightness : [ ☀️ ${scrn_brghtnss}% ]
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
        printf "\e[2J%s\n" "$tooltip_txt" 1>&2
        return 0
    fi

    local tot_charge=0
    local tot_full=0
    local is_charging=false

    for bat in /sys/class/power_supply/BAT*; do
        [ -e "$bat" ] || continue
        if [ -f "$bat/status" ]; then
            local status_val
            status_val=$(cat "$bat/status")
            if [ "$status_val" = "Charging" ]; then
                is_charging=true
            fi
        fi
        if [ -f "$bat/energy_now" ] && [ -f "$bat/energy_full" ]; then
            local now
            local full
            now=$(cat "$bat/energy_now")
            full=$(cat "$bat/energy_full")
            tot_charge=$((tot_charge + now))
            tot_full=$((tot_full + full))
        elif [ -f "$bat/charge_now" ] && [ -f "$bat/charge_full" ]; then
            local now
            local full
            now=$(cat "$bat/charge_now")
            full=$(cat "$bat/charge_full")
            tot_charge=$((tot_charge + now))
            tot_full=$((tot_full + full))
        fi
    done

    local cap=0
    if [ "$tot_full" -gt 0 ]; then
        cap=$(( tot_charge * 100 / tot_full ))
    else
        cap=0
    fi

    local cap_pad
    cap_pad=$(printf "%3d" "$cap")

    local ac_online=0
    [ -f /sys/class/power_supply/AC/online ] && ac_online=$(cat /sys/class/power_supply/AC/online)

    if $is_charging || [ "$ac_online" = "1" ]; then
        IS_NOTIFIED=false
        echo "${PREF}BAT=${BAT_ON} ${cap_pad}%${SEP}AC=${AC_ON}${SUFF}"
        printf "\e[2J%s\n" "$tooltip_txt" 1>&2
    else
        if [ "$ac_online" = "0" ]; then
            local sel_bat_on
            sel_bat_on=$(get_bat_icon "$cap")
            if [ "$cap" -lt 40 ] && ! $IS_NOTIFIED; then
                notify-send "⚠️ Low BAT"
                IS_NOTIFIED=true
            fi
            echo "${PREF}BAT=${sel_bat_on} ${cap_pad}%${SEP}AC=${AC_NONE}${SUFF}"
            printf "\e[2J%s\n" "$tooltip_txt" 1>&2
        else
            echo "${PREF}BAT=${IC_INIT} ${cap_pad}%${SEP}AC=${IC_INIT}${SUFF}"
            printf "\e[2J%s\n" "$tooltip_txt" 1>&2
        fi
    fi
}

print_status
udevadm monitor --udev --subsystem-match=power_supply --subsystem-match=backlight | while read -r ln; do
    if [[ "$ln" == *"UDEV"* ]]; then
        print_status
    fi
done
