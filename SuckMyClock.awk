#!/usr/bin/awk -f

function get_total_days(year, month) {
    split("31 28 31 30 31 30 31 31 30 31 30 31", days, " ")
    if (month == 2) {
        if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
            return 29
        }
    }
    return days[month]
}

BEGIN {
    CMD_CLICK = "lxterminal --geometry=88x28 --working-directory=$HOME -e calcurse"
    mode = "tint2"
    pref = "["
    suff = "]"
    sep = " | "
    use_pango = 0

    for (i = 1; i < ARGC; i++) {
        if (ARGV[i] == "--mode") {
            if (ARGV[i+1] == "tint2" || ARGV[i+1] == "xfce4-panel") {
                mode = ARGV[i+1]
            }
            delete ARGV[i]; delete ARGV[i+1]; i++
        } else if (ARGV[i] == "--pref") {
            pref = ARGV[i+1]; delete ARGV[i]; delete ARGV[i+1]; i++
        } else if (ARGV[i] == "--suff") {
            suff = ARGV[i+1]; delete ARGV[i]; delete ARGV[i+1]; i++
        } else if (ARGV[i] == "--sep") {
            sep = ARGV[i+1]; delete ARGV[i]; delete ARGV[i+1]; i++
        } else if (ARGV[i] == "--pango") {
            use_pango = 1; delete ARGV[i]
        }
    }

    now = systime()
    
    month_num   = strftime("%m", now)
    day_num     = strftime("%d", now)
    year        = strftime("%Y", now) + 0
    month_int   = strftime("%m", now) + 0
    
    total_days  = get_total_days(year, month_int)
    
    date_string = strftime("%a, %d %b %Y", now)
    time_24     = strftime("%H:%M:%S", now)
    time_12     = strftime("%I:%M:%S", now)
    am_pm_str   = strftime("%p", now)
    
    out_string = ""
    if (use_pango) {
        out_string = out_string "<span background='#000000' foreground='#00ADD8'>" pref "</span>"
        out_string = out_string "<span background='#000000' foreground='#CCFF00'>" month_num "/12 </span>"
        out_string = out_string "<span background='#000000' foreground='#FF1493'>months</span>"
        out_string = out_string "<span background='#000000' foreground='#00ADD8'>" sep "</span>"
        out_string = out_string "<span background='#000000' foreground='#CCFF00'>" day_num "/" total_days " </span>"
        out_string = out_string "<span background='#000000' foreground='#FF1493'>days</span>"
        out_string = out_string "<span background='#000000' foreground='#00ADD8'>" sep "</span>"
        out_string = out_string "<span background='#000000' foreground='#CCFF00'>" date_string "</span>"
        out_string = out_string "<span background='#000000' foreground='#00ADD8'>" sep "</span>"
        out_string = out_string "<span background='#000000' foreground='#CCFF00'>" time_24 "</span>"
        out_string = out_string "<span background='#000000' foreground='#00ADD8'>" sep "</span>"
        out_string = out_string "<span background='#000000' foreground='#CCFF00'>" time_12 " </span>"
        out_string = out_string "<span background='#000000' foreground='#FF1493'>" am_pm_str "</span>"
        out_string = out_string "<span background='#000000' foreground='#00ADD8'>" suff "</span>"
    } else {
        out_string = pref month_num "/12 months" sep day_num "/" total_days " days" sep date_string sep time_24 sep time_12 " " am_pm_str suff
    }

    tooltip_txt = "SuckMyClock (My Suckless Clock) Awk version\n" \
                  "click to open calcurse\n"

    if (mode == "xfce4-panel") {
        printf "<txt>%s</txt>\n", out_string
        printf "<txtclick>%s</txtclick>\n", CMD_CLICK
        printf "<tool>%s</tool>\n", tooltip_txt
    } else {
        printf "%s\n", out_string
        printf "\033[2J%s", tooltip_txt > "/dev/stderr"
    }
}
