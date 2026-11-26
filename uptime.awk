#!/usr/bin/awk -f

BEGIN {
    CMD_CLICK = ""
    mode = "tint2"
    pref = "["
    suff = "]"
    use_pango = 0

    for (i = 1; i < ARGC; i++) {
        if (ARGV[i] == "--mode") {
            if (ARGV[i+1] == "tint2" || ARGV[i+1] == "xfce4-panel") {
                mode = ARGV[i+1]
            }
            delete ARGV[i]; delete ARGV[i+1]; i++
        } else if (ARGV[i] == "--pref") {
            pref = ARGV[i+1]
            delete ARGV[i]; delete ARGV[i+1]; i++
        } else if (ARGV[i] == "--suff") {
            suff = ARGV[i+1]
            delete ARGV[i]; delete ARGV[i+1]; i++
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

        k_lbl = "uptime "
        out_string = ""
        
        if (hours < 1000) {
            v_hrs = sprintf("%3d", hours)
            u_hrs = "hours "
            v_min = sprintf("%2d", minutes)
            u_min = "minutes"
            
            if (use_pango) {
                out_string = out_string "<span background='#000000' foreground='#00ADD8'>" pref "</span>"
                out_string = out_string "<span background='#000000' foreground='#FF1493'>" k_lbl "</span>"
                out_string = out_string "<span background='#000000' foreground='#CCFF00'>" v_hrs "</span>"
                out_string = out_string "<span background='#000000' foreground='#FF1493'>" u_hrs "</span>"
                out_string = out_string "<span background='#000000' foreground='#CCFF00'>" v_min "</span>"
                out_string = out_string "<span background='#000000' foreground='#FF1493'>" u_min "</span>"
                out_string = out_string "<span background='#000000' foreground='#00ADD8'>" suff "</span>"
            } else {
                out_string = pref k_lbl v_hrs u_hrs v_min u_min suff
            }
        } else {
            v_hrs = sprintf("%13d", hours)
            u_hrs = "hours"
            if (use_pango) {
                out_string = out_string "<span background='#000000' foreground='#00ADD8'>" pref "</span>"
                out_string = out_string "<span background='#000000' foreground='#FF1493'>" k_lbl "</span>"
                out_string = out_string "<span background='#000000' foreground='#CCFF00'>" v_hrs "</span>"
                out_string = out_string "<span background='#000000' foreground='#FF1493'>" u_hrs "</span>"
                out_string = out_string "<span background='#000000' foreground='#00ADD8'>" suff "</span>"
            } else {
                out_string = pref k_lbl v_hrs u_hrs suff
            }
        }
        
        tooltip_txt = ""
        
        if (mode == "xfce4-panel") {
            printf "<txt>%s</txt>\n", out_string
            printf "<txtclick>%s</txtclick>\n", CMD_CLICK
            printf "<tool>%s</tool>\n", tooltip_txt
        } else {
            printf "%s\n", out_string
            printf "\x1b[2J%s", tooltip_txt > "/dev/stderr"
        }
    }
    close(uptime_file)
}
