#!/usr/bin/env python3

import sys
import datetime
import calendar

def main():
    pref = "| "
    suff = " "
    use_pango = False

    args = sys.argv[1:]
    i = 0
    while i < len(args):
        if args[i] == "--pref" and i + 1 < len(args):
            pref = args[i+1]
            i += 2
        elif args[i] == "--suff" and i + 1 < len(args):
            suff = args[i+1]
            i += 2
        elif args[i] == "--pango":
            use_pango = True
            i += 1
        else:
            i += 1

    now = datetime.datetime.now()

    month_num = now.strftime("%m")
    day_num = now.strftime("%d")
    year = now.year
    month_int = now.month

    total_days = calendar.monthrange(year, month_int)[1]

    date_string = now.strftime("%a, %d %b %Y")
    time_24 = now.strftime("%H:%M:%S")
    time_12 = now.strftime("%I:%M:%S")
    am_pm_str = now.strftime("%p")

    if use_pango:
        out_string = (
            f"<span background='#000000' foreground='#00ADD8'>{pref}</span>"
            f"<span background='#000000' foreground='#CCFF00'>{month_num}/12 </span>"
            f"<span background='#000000' foreground='#FF1493'>months</span>"
            f"<span background='#000000' foreground='#00ADD8'> | </span>"
            f"<span background='#000000' foreground='#CCFF00'>{day_num}/</span>"
            f"<span background='#000000' foreground='#CCFF00'>{total_days} </span>"
            f"<span background='#000000' foreground='#FF1493'>days</span>"
            f"<span background='#000000' foreground='#00ADD8'> | </span>"
            f"<span background='#000000' foreground='#CCFF00'>{date_string}</span>"
            f"<span background='#000000' foreground='#00ADD8'> | </span>"
            f"<span background='#000000' foreground='#CCFF00'>{time_24}</span>"
            f"<span background='#000000' foreground='#00ADD8'> | </span>"
            f"<span background='#000000' foreground='#CCFF00'>{time_12} </span>"
            f"<span background='#000000' foreground='#FF1493'>{am_pm_str}</span>"
            f"<span background='#000000' foreground='#00ADD8'>{suff}</span>"
        )
    else:
        out_string = f"{pref}{month_num}/12 months | {day_num}/{total_days} days | {date_string} | {time_24} | {time_12} {am_pm_str}{suff}"

    print(out_string)

    print(""" SuckMyClock (My Suckless Clock) Python version;
 click to open calcurse""", file=sys.stderr)

if __name__ == "__main__":
    main()
