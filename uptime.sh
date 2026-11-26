#!/bin/sh

CMD_CLICK=""

mode="tint2"
pref="["
suff="]"
use_pango=0

while [ $# -gt 0 ]; do
    case "$1" in
        --mode)
            if [ "$2" = "tint2" ] || [ "$2" = "xfce4-panel" ]; then
                mode="$2"
            fi
            shift 2
            ;;
        --pref)   pref="$2";    shift 2 ;;
        --suff)   suff="$2";    shift 2 ;;
        --pango)  use_pango=1;  shift ;;
        *)                      shift ;;
    esac
done

if [ -r /proc/uptime ]; then
    read -r secs_raw _ < /proc/uptime
    secs=${secs_raw%%.*}
    hours=$((secs / 3600))
    minutes=$(((secs % 3600) / 60))
    if [ "$hours" -gt 9999999999999 ] 2>/dev/null; then
        hours=9999999999999
    fi

    k_lbl="uptime "
    out_string=""
    if [ "$hours" -lt 1000 ]; then
        v_hrs=$(printf "%3d" "$hours")
        u_hrs="hours "
        v_min=$(printf "%2d" "$minutes")
        u_min="minutes"
        if [ "$use_pango" -eq 1 ]; then
            out_string="${out_string}<span background='#000000' foreground='#00ADD8'>$pref</span>"
            out_string="${out_string}<span background='#000000' foreground='#FF1493'>$k_lbl</span>"
            out_string="${out_string}<span background='#000000' foreground='#CCFF00'>$v_hrs</span>"
            out_string="${out_string}<span background='#000000' foreground='#FF1493'>$u_hrs</span>"
            out_string="${out_string}<span background='#000000' foreground='#CCFF00'>$v_min</span>"
            out_string="${out_string}<span background='#000000' foreground='#FF1493'>$u_min</span>"
            out_string="${out_string}<span background='#000000' foreground='#00ADD8'>$suff</span>"
        else
            out_string="${pref}${k_lbl}${v_hrs}${u_hrs}${v_min}${u_min}${suff}"
        fi
    else
        v_hrs=$(printf "%13d" "$hours")
        u_hrs="hours"
        if [ "$use_pango" -eq 1 ]; then
            out_string="${out_string}<span background='#000000' foreground='#00ADD8'>$pref</span>"
            out_string="${out_string}<span background='#000000' foreground='#FF1493'>$k_lbl</span>"
            out_string="${out_string}<span background='#000000' foreground='#CCFF00'>$v_hrs</span>"
            out_string="${out_string}<span background='#000000' foreground='#FF1493'>$u_hrs</span>"
            out_string="${out_string}<span background='#000000' foreground='#00ADD8'>$suff</span>"
        else
            out_string="${pref}${k_lbl}${v_hrs}${u_hrs}${suff}"
        fi
    fi
    tooltip_txt=""
    if [ "$mode" = "xfce4-panel" ]; then
        printf "<txt>%s</txt>\n" "$out_string"
        printf "<txtclick>%s</txtclick>\n" "$CMD_CLICK"
        printf "<tool>%s</tool>\n" "$tooltip_txt"
    else
        printf "%s\n" "$out_string"
        printf "\033[2J%s" "$tooltip_txt" 1>&2
    fi
fi
