#!/bin/bash

IS_INDICATOR=false
IC_ON="👂"
IC_OFF="🚫"
IC_NONE="❌"

PREF=" "
SUFF=" "

while [[ $# -gt 0 ]]; do
    case "$1" in
        --indicator)   IS_INDICATOR=true;  shift ;;
        --ic-on)       IC_ON="$2";         shift 2 ;;
        --ic-off)      IC_OFF="$2";        shift 2 ;;
        --ic-none)     IC_NONE="$2";       shift 2 ;;
        --pref)        PREF="$2";          shift 2 ;;
        --suff)        SUFF="$2";          shift 2 ;;
        *) shift ;;
    esac
done

print_mic_stat() {
    local tooltip_txt=$(cat << EOF
 mic.sh
 --ic-on   = ${IC_ON}
 --ic-off  = ${IC_OFF}
 --ic-none = ${IC_NONE}
 click to open mic.sh;
EOF
    )
    local mic_vol=$(pactl get-source-volume @DEFAULT_SOURCE@ 2>/dev/null | awk '{print $5}' | tr -d '%')
    if [ -z "$mic_vol" ]; then
        echo "${PREF}MIC=${IC_NONE}   0%${SUFF}"
        printf "%s" "$tooltip_txt" 1>&2
        return
    fi
    local mic_pad=$(printf "%3d" "${mic_vol:-0}")
    if [ "$(pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | awk '{print $2}')" = "yes" ]; then
        echo "${PREF}MIC=${IC_OFF} ${mic_pad}%${SUFF}"
    else
        echo "${PREF}MIC=${IC_ON} ${mic_pad}%${SUFF}"
    fi
    printf "%s" "$tooltip_txt" 1>&2
}

if $IS_INDICATOR; then
    print_mic_stat
    pactl subscribe 2>/dev/null | grep --line-buffered "source" | while read -r _; do
        print_mic_stat
    done
    exit 0
fi

alsamixer --view=capture
exit 0
