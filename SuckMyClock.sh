#!/bin/sh

CMD_CLICK="xfce4-terminal -e calcurse"

mode="tint2"
pref="["
suff="]"
sep=" | "
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
        --sep)    sep="$2";     shift 2 ;;
        --pango)  use_pango=1;  shift ;;
        *)                      shift ;;
    esac
done

MONTH_NUM=$(date +"%m")
DAY_NUM=$(date +"%d")
YEAR=$(date +"%Y")
MONTH_INT=$(date +"%m" | sed 's/^0//')

TOTAL_DAYS=$(date -d "$YEAR-$((MONTH_INT+1))-01 -1 day" +"%d" 2>/dev/null || date -d "$YEAR-$MONTH_NUM-01 +1 month -1 day" +"%d")

DATE_STRING=$(date +"%a, %d %b %Y")
TIME_24=$(date +"%H:%M:%S")
TIME_12=$(date +"%I:%M:%S")
AM_PM_STR=$(date +"%p")

if [ "$use_pango" -eq 1 ]; then
    out_string=""
    out_string="${out_string}<span background='#000000' foreground='#00ADD8'>$pref</span>"
    out_string="${out_string}<span background='#000000' foreground='#CCFF00'>${MONTH_NUM}/12 </span>"
    out_string="${out_string}<span background='#000000' foreground='#FF1493'>months</span>"
    out_string="${out_string}<span background='#000000' foreground='#00ADD8'>${sep}</span>"
    out_string="${out_string}<span background='#000000' foreground='#CCFF00'>${DAY_NUM}/${TOTAL_DAYS} </span>"
    out_string="${out_string}<span background='#000000' foreground='#FF1493'>days</span>"
    out_string="${out_string}<span background='#000000' foreground='#00ADD8'>${sep}</span>"
    out_string="${out_string}<span background='#000000' foreground='#CCFF00'>${DATE_STRING}</span>"
    out_string="${out_string}<span background='#000000' foreground='#00ADD8'>${sep}</span>"
    out_string="${out_string}<span background='#000000' foreground='#CCFF00'>${TIME_24}</span>"
    out_string="${out_string}<span background='#000000' foreground='#00ADD8'>${sep}</span>"
    out_string="${out_string}<span background='#000000' foreground='#CCFF00'>${TIME_12} </span>"
    out_string="${out_string}<span background='#000000' foreground='#FF1493'>${AM_PM_STR}</span>"
    out_string="${out_string}<span background='#000000' foreground='#00ADD8'>$suff</span>"
else
    out_string="${pref}${MONTH_NUM}/12 months${sep}${DAY_NUM}/${TOTAL_DAYS} days${sep}${DATE_STRING}${sep}${TIME_24}${sep}${TIME_12} ${AM_PM_STR}${suff}"
fi

tooltip_txt="SuckMyClock (My Suckless Clock) POSIX Shell version
click to open calcurse"

if [ "$mode" = "xfce4-panel" ]; then
    printf "<txt>%s</txt>\n" "$out_string"
    printf "<txtclick>%s</txtclick>\n" "$CMD_CLICK"
    printf "<tool>%s</tool>\n" "$tooltip_txt"
else
    printf "%s\n" "$out_string"
    printf "\e[2J%s\n" "$tooltip_txt" 1>&2
fi
