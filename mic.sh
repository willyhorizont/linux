#!/bin/bash

CMD_CLICK="lxterminal --geometry=88x28 --working-directory=$HOME -e $HOME/willyhorizont.github.io/linux/mic.sh"

declare -A ALL_MODES
ALL_MODES=(
    ["tint2"]="tint2"
    ["xfce4-panel"]="xfce4-panel"
)

IS_INDICATOR=false
MODE="${ALL_MODES["tint2"]}"
GENMON_ID=""
IC_ON="👂"
IC_OFF="🚫"
IC_NONE="❌"

PREF=" "
SUFF=" "

while [[ $# -gt 0 ]]; do
    case "$1" in
        --indicator)   IS_INDICATOR=true;  shift ;;
        --mode)
            if [[ -n "$2" && -n "${ALL_MODES["$2"]}" ]]; then
                MODE="${ALL_MODES["$2"]}"
            fi
            shift 2
            ;;
        --genmon-id)   GENMON_ID="$2";     shift 2 ;;
        --ic-on)       IC_ON="$2";         shift 2 ;;
        --ic-off)      IC_OFF="$2";        shift 2 ;;
        --ic-none)     IC_NONE="$2";       shift 2 ;;
        --pref)        PREF="$2";          shift 2 ;;
        --suff)        SUFF="$2";          shift 2 ;;
        *)                                 shift ;;
    esac
done

get_mic_stat() {
    local mic_vol
    mic_vol=$(pactl get-source-volume @DEFAULT_SOURCE@ 2>/dev/null | awk '{print $5}' | tr -d '%')
    if [ -z "$mic_vol" ]; then
        STATE="NONE"
        OUT_TXT="${PREF}MIC=${IC_NONE}   0%${SUFF}"
        return 0
    fi
    local mic_pad
    mic_pad=$(printf "%3d" "${mic_vol:-0}")
    if [ "$(pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | awk '{print $2}')" = "yes" ]; then
        STATE="OFF"
        OUT_TXT="${PREF}MIC=${IC_OFF} ${mic_pad}%${SUFF}"
    else
        STATE="ON"
        OUT_TXT="${PREF}MIC=${IC_ON} ${mic_pad}%${SUFF}"
    fi
}

print_indicator() {
    get_mic_stat
    local tooltip_txt
    tooltip_txt=$(cat << EOF
mic.sh
--ic-on   = ${IC_ON}
--ic-off  = ${IC_OFF}
--ic-none = ${IC_NONE}
click to open mic.sh
EOF
    )
    if [ "$MODE" = "${ALL_MODES["xfce4-panel"]}" ]; then
        echo "<txt>${OUT_TXT}</txt>"
        echo "<txtclick>$CMD_CLICK</txtclick>"
        echo "<tool>$tooltip_txt</tool>"
    else
        echo "${OUT_TXT}"
        printf "\e[2J%s\n" "$tooltip_txt" 1>&2
    fi
}

if $IS_INDICATOR; then
    print_indicator
    if [ "$MODE" = "${ALL_MODES["xfce4-panel"]}" ]; then
        [ -z "$GENMON_ID" ] && exit 0
        pgrep -f ".*pactl subscribe.*source.*xfce4-panel.*--plugin-event.*:refresh:bool:true.*" >/dev/null && exit 0
        setsid -f bash -c 'pactl subscribe 2>/dev/null | grep --line-buffered "source" | while read -r _; do pgrep -x "xfce4-panel" >/dev/null && xfce4-panel --plugin-event="$1:refresh:bool:true" >/dev/null 2>&1; done' _ "$GENMON_ID" >/dev/null 2>&1
        exit 0
    fi
    pactl subscribe 2>/dev/null | grep --line-buffered "source" | while read -r _; do
        print_indicator
    done
    exit 0
fi

alsamixer --view=capture
exit 0
