#!/usr/bin/awk -f

function pad(str, len) {
    return sprintf("%*s", len, str)
}

function fmt(bytesps,    units, i, v, num_str, split_arr, f_p, b_p) {
    if (bytesps <= 0) return "      0B/s"
    units[0] = "B/s"; units[1] = "KB/s"; units[2] = "MB/s"
    i = 0
    v = bytesps
    while (v >= 1024 && i < 2) {
        v /= 1024
        i++
    }
    num_str = (i == 0) ? sprintf("%.3f", v) : sprintf("%.2f", v)
    split(num_str, split_arr, ".")
    f_p = split_arr[1]
    b_p = split_arr[2]
    if (length(f_p) > 3) return "999999GB/s"
    f_p = pad(f_p, 3)
    return f_p "." b_p units[i]
}

BEGIN {
    CACHE_FILE = "/tmp/sprm-awk-cache.json"
    
    NET_INTRF = "lo"
    while ((getline < "/proc/net/route") > 0) {
        if ($2 == "00000000" && $1 != "lo") {
            NET_INTRF = $1
            break
        }
    }
    close("/proc/net/route")
    
    if (NET_INTRF == "lo") {
        while ((getline < "/proc/net/dev") > 0) {
            if ($1 ~ /^[a-zA-Z0-9_-]+:/) {
                split($1, arr, ":")
                candidate = arr[1]
                if (candidate != "lo" && candidate !~ /^(sit|docker|veth|br-|virbr)/) {
                    NET_INTRF = candidate
                    break
                }
            }
        }
        close("/proc/net/dev")
    }
    
    temp = 0.0
    for (zone = 0; zone <= 5; zone++) {
        t_file = "/sys/class/thermal/thermal_zone" zone "/temp"
        if ((getline < t_file) > 0) {
            t_val = $1
            close(t_file)
            if (t_val > 0) {
                temp = t_val / 1000
                break
            }
        }
        close(t_file)
    }
    
    while ((getline < "/proc/stat") > 0) {
        if ($1 == "cpu") {
            user = $2; nice = $3; system_t = $4; idle = $5; iowait = $6; irq = $7; softirq = $8
            break
        }
    }
    close("/proc/stat")
    
    gpu = 0.0
    amd_file = "/sys/class/drm/card0/device/gpu_busy_percent"
    intel_act = "/sys/class/drm/card0/gt_act_freq_mhz"
    intel_max = "/sys/class/drm/card0/gt_max_freq_mhz"
    
    if ((getline < amd_file) > 0) {
        gpu = $1
        close(amd_file)
    } else {
        close(amd_file)
        act_val = 0; max_val = 1
        if ((getline < intel_act) > 0) { act_val = $1; close(intel_act) }
        if ((getline < intel_max) > 0) { max_val = $1; close(intel_max) }
        if (max_val > 0) gpu = (act_val / max_val) * 100
    }
    
    while ((getline < "/proc/meminfo") > 0) {
        if ($1 == "MemTotal:") mem_t = $2
        if ($1 == "MemAvailable:") mem_a = $2
    }
    close("/proc/meminfo")
    ram_used = (mem_t - mem_a) / 1024 / 1024
    ram_tot = mem_t / 1024 / 1024
    
    row = 0
    while (("df -B1 / 2>/dev/null" | getline line) > 0) {
        row++
        if (row == 1) continue
        split(line, df_p)
        d_tot_GB = df_p[2] / 1e9
        d_free_GB = df_p[4] / 1e9
    }
    close("df -B1 / 2>/dev/null")
    
    cur_d_r = 0; cur_d_w = 0
    while ((getline < "/proc/diskstats") > 0) {
        if ($3 ~ /^(sd[a-z]|nvme[0-9]+n[0-9]+|mmcblk[0-9]+|vd[a-z])$/) {
            cur_d_r += $6
            cur_d_w += $10
        }
    }
    close("/proc/diskstats")
    cur_d_r *= 512
    cur_d_w *= 512
    
    cur_net_down = 0; cur_net_up = 0
    while ((getline < "/proc/net/dev") > 0) {
        if ($0 ~ NET_INTRF) {
            sub(/^[^:]*:/, "", $0)
            split($0, net_p)
            cur_net_down = net_p[1]
            cur_net_up = net_p[9]
            break
        }
    }
    close("/proc/net/dev")
    
    "date +%s.%N" | getline now_time
    close("date +%s.%N")
    
    old_time = 0; old_d_r = 0; old_d_w = 0; old_n_d = 0; old_n_u = 0
    has_time = 0; has_dr = 0; has_dw = 0; has_nd = 0; has_nu = 0
    split("0,0,0,0,0,0,0", old_cpu, ",")
    
    if ((getline < CACHE_FILE) > 0) {
        ctx = $0
        if (ctx ~ /"time":/) {
            match(ctx, /"time":([0-9.]+)/, m) ; old_time = m[1]; has_time = 1
            match(ctx, /"d_r":([0-9]+)/, m) ; old_d_r = m[1]; has_dr = 1
            match(ctx, /"d_w":([0-9]+)/, m) ; old_d_w = m[1]; has_dw = 1
            match(ctx, /"n_d":([0-9]+)/, m) ; old_n_d = m[1]; has_nd = 1
            match(ctx, /"n_u":([0-9]+)/, m) ; old_n_u = m[1]; has_nu = 1
            match(ctx, /"cpu":\[([0-9,]+)\]/, m)
            split(m[1], old_cpu, ",")
        }
    }
    close(CACHE_FILE)
    
    time_d = has_time ? (now_time - old_time) : (now_time - (now_time - 2.0))
    if (time_d <= 0) time_d = 2.0
    
    old_idle = old_cpu[4] + old_cpu[5]
    new_idle = idle + iowait
    old_non_idle = old_cpu[1] + old_cpu[2] + old_cpu[3] + old_cpu[6] + old_cpu[7]
    new_non_idle = user + nice + system_t + irq + softirq
    
    tot_old = old_idle + old_non_idle
    tot_new = new_idle + new_non_idle
    tot_delta = tot_new - tot_old
    idle_delta = new_idle - old_idle
    
    cpu_pcent = (tot_delta > 0) ? (((tot_delta - idle_delta) / tot_delta) * 100) : 0.0
    cpu_fmt = pad(sprintf("%.1f", cpu_pcent), 5)
    
    r_rt = has_dr ? ((cur_d_r - old_d_r) / time_d) : 0.0
    w_rt = has_dw ? ((cur_d_w - old_d_w) / time_d) : 0.0
    d_rt = has_nd ? ((cur_net_down - old_n_d) / time_d) : 0.0
    u_rt = has_nu ? ((cur_net_up - old_n_u) / time_d) : 0.0
    
    if (r_rt < 0) r_rt = 0; if (w_rt < 0) w_rt = 0
    if (d_rt < 0) d_rt = 0; if (u_rt < 0) u_rt = 0
    
    print "{\"time\":" now_time ",\"cpu\":[" user "," nice "," system_t "," idle "," iowait "," irq "," softirq "],\"d_r\":" cur_d_r ",\"d_w\":" cur_d_w ",\"n_d\":" cur_net_down ",\"n_u\":" cur_net_up "}" > CACHE_FILE
    close(CACHE_FILE)
    
    temp_str = (temp >= 100.0) ? "9999" : sprintf("%.1f", temp)
    gpu_fmt = pad(sprintf("%.1f", gpu), 5)
    ram_used_str = pad(sprintf("%.2f", ram_used), 5)
    ram_tot_str = sprintf("%.2f", ram_tot)
    d_free_str = sprintf("%.2f", d_free_GB)
    d_tot_str = sprintf("%.2f", d_tot_GB)
    
    out_t = (temp_str == "9999") ? "9999°C" : temp_str "°C"
    
    f_r = fmt(r_rt); f_w = fmt(w_rt); f_d = fmt(d_rt); f_u = fmt(u_rt)
    out_r = (f_r ~ /999999/) ? "999999GB/s" : f_r
    out_w = (f_w ~ /999999/) ? "999999GB/s" : f_w
    out_d = (f_d ~ /999999/) ? "999999GB/s" : f_d
    out_u = (f_u ~ /999999/) ? "999999GB/s" : f_u
    
    printf " T %s | C %s%% | G %s%% | M %s/%sGB | D %s/%sGB | R %s | W %s | ▼ %s | ▲ %s |", out_t, cpu_fmt, gpu_fmt, ram_used_str, ram_tot_str, d_free_str, d_tot_str, out_r, out_w, out_d, out_u
}
