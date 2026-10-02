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
    now = systime()
    
    month_num   = strftime("%m", now)
    day_num     = strftime("%d", now)
    year        = strftime("%Y", now) + 0
    month_int   = strftime("%m", now) + 0
    
    total_days  = get_total_days(year, month_int)
    
    date_string = strftime("%a, %d %b %Y", now)
    time_24     = strftime("%H:%M:%S", now)
    time_12     = strftime("%I:%M:%S %p", now)
    
    printf "| %s/12 months | %s/%d days | %s | %s | %s ", month_num, day_num, total_days, date_string, time_24, time_12
    print "\n" \
        "`                  \n" \
        "    SuckMyClock    \n" \
        "  * Awk version *  \n" \
        "                  .\n" > "/dev/stderr"
}
