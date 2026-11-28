#!/usr/bin/env python3

import sys
import datetime
import calendar

CMD_CLICK = "xfce4-terminal -e calcurse"


def main():
    mode = "tint2"
    pref = "["
    suff = "]"
    sep = " | "
    use_pango = False

    args = sys.argv[1:]
    i = 0
    while i < len(args):
        if args[i] == "--mode" and i + 1 < len(args):
            if args[i + 1] in ("tint2", "xfce4-panel"):
                mode = args[i + 1]
            i += 2
        elif args[i] == "--pref" and i + 1 < len(args):
            pref = args[i + 1]
            i += 2
        elif args[i] == "--suff" and i + 1 < len(args):
            suff = args[i + 1]
            i += 2
        elif args[i] == "--sep" and i + 1 < len(args):
            sep = args[i + 1]
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
        out_string = ""
        out_string += f"<span background='#000000' foreground='#00ADD8'>{pref}</span>"
        out_string += f"<span background='#000000' foreground='#CCFF00'>{month_num}/12 </span>"
        out_string += f"<span background='#000000' foreground='#FF1493'>months</span>"
        out_string += f"<span background='#000000' foreground='#00ADD8'>{sep}</span>"
        out_string += f"<span background='#000000' foreground='#CCFF00'>{day_num}/{total_days} </span>"
        out_string += f"<span background='#000000' foreground='#FF1493'>days</span>"
        out_string += f"<span background='#000000' foreground='#00ADD8'>{sep}</span>"
        out_string += f"<span background='#000000' foreground='#CCFF00'>{date_string}</span>"
        out_string += f"<span background='#000000' foreground='#00ADD8'>{sep}</span>"
        out_string += f"<span background='#000000' foreground='#CCFF00'>{time_24}</span>"
        out_string += f"<span background='#000000' foreground='#00ADD8'>{sep}</span>"
        out_string += f"<span background='#000000' foreground='#CCFF00'>{time_12} </span>"
        out_string += f"<span background='#000000' foreground='#FF1493'>{am_pm_str}</span>"
        out_string += f"<span background='#000000' foreground='#00ADD8'>{suff}</span>"
    else:
        out_string = f"{pref}{month_num}/12 months{sep}{day_num}/{total_days} days{sep}{date_string}{sep}{time_24}{sep}{time_12} {am_pm_str}{suff}"

    tooltip_txt = (
        "SuckMyClock (My Suckless Clock) Python version\n"
        "click to open calcurse"
    )

    if mode == "xfce4-panel":
        print(f"<txt>{out_string}</txt>")
        print(f"<txtclick>{CMD_CLICK}</txtclick>")
        print(f"<tool>{tooltip_txt}</tool>")
    else:
        print(out_string)
        print(f"\x1b[2J{tooltip_txt}", end="", file=sys.stderr)


if __name__ == "__main__":
    main()
