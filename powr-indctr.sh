#!/bin/bash

CMD_CLICK="xfce4-terminal -e $HOME/willyhorizont.github.io/linux/powr-mgr.sh"

declare -A ALL_MODES
ALL_MODES=(
    ["tint2"]="tint2"
    ["xfce4-panel"]="xfce4-panel"
)

MODE="${ALL_MODES["tint2"]}"
GENMON_ID=""
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
USE_PANGO=false
USE_DARK=false

HAS_BAT_HI=false
HAS_BAT_LO=false
HAS_BAT_ON=false

STATE_NOTIFIED_DIR="/tmp/low-bat-notified.lock"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --mode)
            if [[ -n "$2" && -n "${ALL_MODES["$2"]}" ]]; then
                MODE="${ALL_MODES["$2"]}"
            fi
            shift 2
            ;;
        --genmon-id)  GENMON_ID="$2";                    shift 2 ;;
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
        --pango)      USE_PANGO=true;                    shift ;;
        --dark)       USE_DARK=true;                     shift ;;
        *)                                               shift ;;
    esac
done

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

OUT_TXT=""

format_out() {
    local bat_ic="$1"
    local cap_val="$2"
    local ac_ic="$3"
    if $USE_PANGO; then
        if $USE_DARK; then
            OUT_TXT="${OUT_TXT}<span background='#000000' foreground='#00ADD8'>${PREF}</span>"
            OUT_TXT="${OUT_TXT}<span background='#000000' foreground='#FF1493'>BAT </span>"
            OUT_TXT="${OUT_TXT}<span background='#000000' foreground='#CCFF00'>${bat_ic} ${cap_val}</span>"
            OUT_TXT="${OUT_TXT}<span background='#000000' foreground='#FF1493'>%</span>"
            OUT_TXT="${OUT_TXT}<span background='#000000' foreground='#00ADD8'>${SEP}</span>"
            OUT_TXT="${OUT_TXT}<span background='#000000' foreground='#FF1493'>AC </span>"
            OUT_TXT="${OUT_TXT}<span background='#000000' foreground='#CCFF00'>${ac_ic}</span>"
            OUT_TXT="${OUT_TXT}<span background='#000000' foreground='#00ADD8'>${SUFF}</span>"
        else
            OUT_TXT="${OUT_TXT}<span background='#FFFFFF' foreground='#000000'>${PREF}</span>"
            OUT_TXT="${OUT_TXT}<span background='#FFFFFF' foreground='#000000'>BAT </span>"
            OUT_TXT="${OUT_TXT}<span background='#FFFFFF' foreground='#000000'>${bat_ic} ${cap_val}</span>"
            OUT_TXT="${OUT_TXT}<span background='#FFFFFF' foreground='#000000'>%</span>"
            OUT_TXT="${OUT_TXT}<span background='#FFFFFF' foreground='#000000'>${SEP}</span>"
            OUT_TXT="${OUT_TXT}<span background='#FFFFFF' foreground='#000000'>AC </span>"
            OUT_TXT="${OUT_TXT}<span background='#FFFFFF' foreground='#000000'>${ac_ic}</span>"
            OUT_TXT="${OUT_TXT}<span background='#FFFFFF' foreground='#000000'>${SUFF}</span>"
        fi
    else
        OUT_TXT="${PREF}BAT ${bat_ic} ${cap_val}%${SEP}AC ${ac_ic}${SUFF}"
    fi
}

get_powr_stat() {
    if [ ! -d /sys/class/power_supply ] || [ -z "$(ls /sys/class/power_supply/ | grep -E '^BAT|^battery')" ]; then
        format_out "${BAT_NONE}" "  0" "${AC_ON}"
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
    fi

    local cap_pad
    cap_pad=$(printf "%3d" "$cap")

    local ac_online=0
    [ -f /sys/class/power_supply/AC/online ] && ac_online=$(cat /sys/class/power_supply/AC/online)

    if $is_charging || [ "$ac_online" = "1" ]; then
        rmdir "$STATE_NOTIFIED_DIR" 2>/dev/null
        format_out "${BAT_ON}" "${cap_pad}" "${AC_ON}"
    elif [ "$ac_online" = "0" ]; then
        local sel_bat_on
        sel_bat_on=$(get_bat_icon "$cap")
        if [ "$cap" -lt 40 ] && mkdir "$STATE_NOTIFIED_DIR" 2>/dev/null; then
            notify-send "⚠️ Low BAT"
        fi
        format_out "${sel_bat_on}" "${cap_pad}" "${AC_NONE}"
    else
        format_out "${IC_INIT}" "${cap_pad}" "${IC_INIT}"
    fi
}

print_indicator() {
    local scrn_brghtnss
    scrn_brghtnss=$("$HOME/willyhorizont.github.io/linux/scrn-brghtnss-mgr.sh" --print)

    get_powr_stat

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

    if [ "$MODE" = "${ALL_MODES["xfce4-panel"]}" ]; then
        echo "<txt>${OUT_TXT}</txt>"
        echo "<txtclick>$CMD_CLICK</txtclick>"
        echo "<tool>$tooltip_txt</tool>"
    else
        echo "${OUT_TXT}"
        printf "\e[2J%s\n" "$tooltip_txt" 1>&2
    fi
}

print_indicator

if [ "$MODE" = "${ALL_MODES["xfce4-panel"]}" ]; then
    [ -z "$GENMON_ID" ] && exit 0
    pgrep -f ".*udevadm monitor --udev --subsystem-match=power_supply --subsystem-match=backlight.*xfce4-panel.*--plugin-event.*:refresh:bool:true.*" >/dev/null && exit 0
    setsid -f bash -c 'udevadm monitor --udev --subsystem-match=power_supply --subsystem-match=backlight 2>/dev/null | while read -r ln; do [[ "$ln" == *"UDEV"* ]] && pgrep -x "xfce4-panel" >/dev/null && xfce4-panel --plugin-event="$1:refresh:bool:true" >/dev/null 2>&1; done' _ "$GENMON_ID" >/dev/null 2>&1
    exit 0
fi

udevadm monitor --udev --subsystem-match=power_supply --subsystem-match=backlight 2>/dev/null | while read -r ln; do
    if [[ "$ln" == *"UDEV"* ]]; then
        print_indicator
    fi
done
