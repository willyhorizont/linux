#!/bin/bash

IS_INDICATOR=false
IC_INIT="⏳"
IC_ON="🚨"
IC_OFF="🚫"
IC_NONE="❌"

PREF=""
SUFF=" | "

while [[ $# -gt 0 ]]; do
    case "$1" in
        --indicator)   IS_INDICATOR=true;  shift ;;
        --ic-init)     IC_INIT="$2";       shift 2 ;;
        --ic-on)       IC_ON="$2";         shift 2 ;;
        --ic-off)      IC_OFF="$2";        shift 2 ;;
        --ic-none)     IC_NONE="$2";       shift 2 ;;
        --pref)        PREF="$2";          shift 2 ;;
        --suff)        SUFF="$2";          shift 2 ;;
        *)                                 shift ;;
    esac
done

print_vol_stat() {
    local tooltip_txt
    tooltip_txt=$(cat << EOF
 vol.sh
 --ic-init = ${IC_INIT}
 --ic-on   = ${IC_ON}
 --ic-off  = ${IC_OFF}
 --ic-none = ${IC_NONE}
 click to open vol.sh;
EOF
    )
    local vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk '{print $5}' | tr -d '%')
    if [ -z "$vol" ]; then
        echo "${PREF}VOL=${IC_NONE}   0%${SUFF}"
        printf "%s" "$tooltip_txt" 1>&2
        return
    fi
    local vol_pad=$(printf "%3d" "${vol:-0}")
    if [ "$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}')" = "yes" ]; then
        echo "${PREF}VOL=${IC_OFF} ${vol_pad}%${SUFF}"
    else
        echo "${PREF}VOL=${IC_ON} ${vol_pad}%${SUFF}"
    fi
    printf "%s" "$tooltip_txt" 1>&2
}

if $IS_INDICATOR; then
    print_vol_stat
    pactl subscribe 2>/dev/null | grep --line-buffered "sink" | while read -r _; do
        print_vol_stat
    done
    exit 0
fi

alsamixer --view=playback
exit 0
