#!/usr/bin/awk -f

BEGIN {
    pref = ""
    suff = " |"
    use_pango = 0

    for (i = 1; i < ARGC; i++) {
        if (ARGV[i] == "--pref") {
            pref = ARGV[i+1]
            delete ARGV[i]
            delete ARGV[i+1]
            i++
        } else if (ARGV[i] == "--suff") {
            suff = ARGV[i+1]
            delete ARGV[i]
            delete ARGV[i+1]
            i++
        } else if (ARGV[i] == "--pango") {
            use_pango = 1
            delete ARGV[i]
        }
    }

    uptime_file = "/proc/uptime"
    if ((getline < uptime_file) > 0) {
        secs = $1
        hours = int(secs / 3600)
        minutes = int((secs % 3600) / 60)
        
        if (hours > 9999999999999) {
            hours = 9999999999999
        }

        k_lbl = " uptime "
        
        if (hours < 1000) {
            v_hrs = sprintf("%3d", hours)
            u_hrs = "hours "
            v_min = sprintf("%02d", minutes)
            u_min = "minutes"
            
            if (use_pango) {
                out_string = "<span background='#000000' foreground='#00ADD8'>" pref "</span>" \
                             "<span background='#000000' foreground='#FF1493'>" k_lbl "</span>" \
                             "<span background='#000000' foreground='#CCFF00'>" v_hrs "</span>" \
                             "<span background='#000000' foreground='#FF1493'>" u_hrs "</span>" \
                             "<span background='#000000' foreground='#CCFF00'>" v_min "</span>" \
                             "<span background='#000000' foreground='#FF1493'>" u_min "</span>" \
                             "<span background='#000000' foreground='#00ADD8'>" suff "</span>"
            } else {
                out_string = pref k_lbl v_hrs u_hrs v_min u_min suff
            }
        } else {
            v_hrs = sprintf("%13d", hours)
            u_hrs = "hours"
            if (use_pango) {
                out_string = "<span background='#000000' foreground='#00ADD8'>" pref "</span>" \
                             "<span background='#000000' foreground='#FF1493'>" k_lbl "</span>" \
                             "<span background='#000000' foreground='#CCFF00'>" v_hrs "</span>" \
                             "<span background='#000000' foreground='#FF1493'>" u_hrs "</span>" \
                             "<span background='#000000' foreground='#00ADD8'>" suff "</span>"
            } else {
                out_string = pref k_lbl v_hrs u_hrs suff
            }
        }
        
        printf "%s\n", out_string
    }
    close(uptime_file)
}
