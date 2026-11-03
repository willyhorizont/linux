#!/bin/sh

pref="| "
suff=" "
use_pango=0

while [ $# -gt 0 ]; do
    case "$1" in
        --pref) pref="$2"; shift 2 ;;
        --suff) suff="$2"; shift 2 ;;
        --pango) use_pango=1; shift ;;
        *) shift ;;
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
    out_string="<span background='#000000' foreground='#00ADD8'>$pref</span>"
    out_string="${out_string}<span background='#000000' foreground='#CCFF00'>${MONTH_NUM}/12 </span>"
    out_string="${out_string}<span background='#000000' foreground='#FF1493'>months</span>"
    out_string="${out_string}<span background='#000000' foreground='#00ADD8'> | </span>"
    out_string="${out_string}<span background='#000000' foreground='#CCFF00'>${DAY_NUM}/</span>"
    out_string="${out_string}<span background='#000000' foreground='#CCFF00'>${TOTAL_DAYS} </span>"
    out_string="${out_string}<span background='#000000' foreground='#FF1493'>days</span>"
    out_string="${out_string}<span background='#000000' foreground='#00ADD8'> | </span>"
    out_string="${out_string}<span background='#000000' foreground='#CCFF00'>${DATE_STRING}</span>"
    out_string="${out_string}<span background='#000000' foreground='#00ADD8'> | </span>"
    out_string="${out_string}<span background='#000000' foreground='#CCFF00'>${TIME_24}</span>"
    out_string="${out_string}<span background='#000000' foreground='#00ADD8'> | </span>"
    out_string="${out_string}<span background='#000000' foreground='#CCFF00'>${TIME_12} </span>"
    out_string="${out_string}<span background='#000000' foreground='#FF1493'>${AM_PM_STR}</span>"
    out_string="${out_string}<span background='#000000' foreground='#00ADD8'>$suff</span>"
else
    out_string="${pref}${MONTH_NUM}/12 months | ${DAY_NUM}/${TOTAL_DAYS} days | ${DATE_STRING} | ${TIME_24} | ${TIME_12} ${AM_PM_STR}${suff}"
fi

printf "%s\n" "$out_string"

cat << EOF 1>&2
 SuckMyClock (My Suckless Clock) Shell version
 click to open calcurse
EOF
