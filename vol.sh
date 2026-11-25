#!/bin/bash

CMD_CLICK="lxterminal --geometry=88x28 --working-directory=$HOME -e $HOME/willyhorizont.github.io/linux/vol.sh"

declare -A ALL_MODES
ALL_MODES=(
    ["tint2"]="tint2"
    ["xfce4-panel"]="xfce4-panel"
)

IS_INDICATOR=false
MODE="${ALL_MODES["tint2"]}"
GENMON_ID=""
IC_INIT="⏳"
IC_ON="🚨"
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
        --ic-init)     IC_INIT="$2";       shift 2 ;;
        --ic-on)       IC_ON="$2";         shift 2 ;;
        --ic-off)      IC_OFF="$2";        shift 2 ;;
        --ic-none)     IC_NONE="$2";       shift 2 ;;
        --pref)        PREF="$2";          shift 2 ;;
        --suff)        SUFF="$2";          shift 2 ;;
        *)                                 shift ;;
    esac
done

get_vol_stat() {
    local vol
    vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk '{print $5}' | tr -d '%')
    if [ -z "$vol" ]; then
        STATE="NONE"
        OUT_TXT="${PREF}VOL=${IC_NONE}   0%${SUFF}"
        return 0
    fi
    local vol_pad
    vol_pad=$(printf "%3d" "${vol:-0}")
    if [ "$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}')" = "yes" ]; then
        STATE="OFF"
        OUT_TXT="${PREF}VOL=${IC_OFF} ${vol_pad}%${SUFF}"
    else
        STATE="ON"
        OUT_TXT="${PREF}VOL=${IC_ON} ${vol_pad}%${SUFF}"
    fi
}

print_indicator() {
    get_vol_stat
    local tooltip_txt
    tooltip_txt=$(cat << EOF
vol.sh
--ic-init = ${IC_INIT}
--ic-on   = ${IC_ON}
--ic-off  = ${IC_OFF}
--ic-none = ${IC_NONE}
click to open vol.sh
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
        pgrep -f ".*pactl subscribe.*sink.*xfce4-panel.*--plugin-event.*:refresh:bool:true.*" >/dev/null && exit 0
        setsid -f bash -c '
            pactl subscribe 2>/dev/null | grep --line-buffered "sink" | while read -r _; do
                if pgrep -x "xfce4-panel" >/dev/null; then
                    xfce4-panel --plugin-event="$1:refresh:bool:true" >/dev/null 2>&1
                fi
            done
        ' _ "$GENMON_ID" >/dev/null 2>&1
        exit 0
    fi
    pactl subscribe 2>/dev/null | grep --line-buffered "sink" | while read -r _; do
        print_indicator
    done
    exit 0
fi

alsamixer --view=playback
exit 0
