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
    pref = "| "
    suff = " "
    use_pango = 0

    for (i = 1; i < ARGC; i++) {
        if (ARGV[i] == "--pref") {
            pref = ARGV[i+1]; delete ARGV[i]; delete ARGV[i+1]; i++
        } else if (ARGV[i] == "--suff") {
            suff = ARGV[i+1]; delete ARGV[i]; delete ARGV[i+1]; i++
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
    
    if (use_pango) {
        out_string = "<span background='#000000' foreground='#00ADD8'>" pref "</span>" \
                     "<span background='#000000' foreground='#CCFF00'>" month_num "/12 </span>" \
                     "<span background='#000000' foreground='#FF1493'>months</span>" \
                     "<span background='#000000' foreground='#00ADD8'> | </span>" \
                     "<span background='#000000' foreground='#CCFF00'>" day_num "/" total_days " </span>" \
                     "<span background='#000000' foreground='#FF1493'>days</span>" \
                     "<span background='#000000' foreground='#00ADD8'> | </span>" \
                     "<span background='#000000' foreground='#CCFF00'>" date_string "</span>" \
                     "<span background='#000000' foreground='#00ADD8'> | </span>" \
                     "<span background='#000000' foreground='#CCFF00'>" time_24 "</span>" \
                     "<span background='#000000' foreground='#00ADD8'> | </span>" \
                     "<span background='#000000' foreground='#CCFF00'>" time_12 " </span>" \
                     "<span background='#000000' foreground='#FF1493'>" am_pm_str "</span>" \
                     "<span background='#000000' foreground='#00ADD8'>" suff "</span>"
    } else {
        out_string = pref month_num "/12 months | " day_num "/" total_days " days | " date_string " | " time_24 " | " time_12 " " am_pm_str suff
    }

    printf "%s\n", out_string

    print " SuckMyClock Awk version;\n" \
          " click to open calcurse\n" > "/dev/stderr"
}
