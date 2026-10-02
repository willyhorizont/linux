#!/bin/sh

CACHE_FILE="/tmp/sprm-dash-cache.json"

NET_INTRF="lo"
if [ -r /proc/net/route ]; then
    ROUTE_LINE=$(sed -n '/^[a-zA-Z0-9_-]\{1,\}[[:space:]]\{1,\}00000000[[:space:]]/p' /proc/net/route | head -n 1)
    if [ -n "$ROUTE_LINE" ]; then
        NET_INTRF=$(echo "$ROUTE_LINE" | sed 's/[[:space:]].*//')
    fi
fi

if [ "$NET_INTRF" = "lo" ] && [ -r /proc/net/dev ]; then
    while read -r line; do
        candidate=$(echo "$line" | sed -n 's/^[[:space:]]*\([a-zA-Z0-9_-]\{1,\}\):.*/\1/p')
        if [ -n "$candidate" ] && [ "$candidate" != "lo" ]; then
            if ! echo "$candidate" | grep -qE '^(sit|docker|veth|br-|virbr)'; then
                NET_INTRF="$candidate"
                break
            fi
        fi
    done < /proc/net/dev
fi

temp_raw=0
for zone in 0 1 2 3 4 5; do
    if [ -r "/sys/class/thermal/thermal_zone$zone/temp" ]; then
        t=$(cat "/sys/class/thermal/thermal_zone$zone/temp")
        if [ "$t" -gt 0 ] 2>/dev/null; then temp_raw=$t; break; fi
    fi
done

CPU_LINE=$(sed -n '/^cpu /p' /proc/stat)
user=$(echo "$CPU_LINE" | sed 's/^cpu[[:space:]]\{1,\}\([0-9]\{1,\}\).*/\1/')
nice=$(echo "$CPU_LINE" | sed 's/^cpu[[:space:]]\{1,\}[0-9]\{1,\}[[:space:]]\{1,\}\([0-9]\{1,\}\).*/\1/')
system_t=$(echo "$CPU_LINE" | sed 's/^cpu[[:space:]]\{1,\}\([0-9]\{1,\}[[:space:]]\{1,\}\)\{2\}\([0-9]\{1,\}\).*/\2/')
idle=$(echo "$CPU_LINE" | sed 's/^cpu[[:space:]]\{1,\}\([0-9]\{1,\}[[:space:]]\{1,\}\)\{3\}\([0-9]\{1,\}\).*/\2/')
iowait=$(echo "$CPU_LINE" | sed 's/^cpu[[:space:]]\{1,\}\([0-9]\{1,\}[[:space:]]\{1,\}\)\{4\}\([0-9]\{1,\}\).*/\2/')
irq=$(echo "$CPU_LINE" | sed 's/^cpu[[:space:]]\{1,\}\([0-9]\{1,\}[[:space:]]\{1,\}\)\{5\}\([0-9]\{1,\}\).*/\2/')
softirq=$(echo "$CPU_LINE" | sed 's/^cpu[[:space:]]\{1,\}\([0-9]\{1,\}[[:space:]]\{1,\}\)\{6\}\([0-9]\{1,\}\).*/\2/')

gpu_pcent=0
# AMD
if [ -r /sys/class/drm/card0/device/gpu_busy_percent ]; then
    gpu_pcent=$(cat /sys/class/drm/card0/device/gpu_busy_percent)
# Intel
elif [ -r /sys/class/drm/card0/gt_act_freq_mhz ] && [ -r /sys/class/drm/card0/gt_max_freq_mhz ]; then
    act=$(cat /sys/class/drm/card0/gt_act_freq_mhz)
    max=$(cat /sys/class/drm/card0/gt_max_freq_mhz)
    if [ "$max" -gt 0 ] 2>/dev/null; then
        gpu_pcent=$(echo "scale=1; ($act / $max) * 100" | bc)
    fi
fi

mem_t=$(sed -n 's/^MemTotal:[[:space:]]*\([0-9]*\).*/\1/p' /proc/meminfo)
mem_a=$(sed -n 's/^MemAvailable:[[:space:]]*\([0-9]*\).*/\1/p' /proc/meminfo)

DF_LINE=$(df -B1 / 2>/dev/null | tail -n +2 | head -n 1)
d_tot_bytes=$(echo "$DF_LINE" | sed 's/^[^[:space:]]\{1,\}[[:space:]]\{1,\}\([0-9]\{1,\}\).*/\1/')
d_free_bytes=$(echo "$DF_LINE" | sed 's/^\([^[:space:]]\{1,\}[[:space:]]\{1,\}\)\{3\}\([0-9]\{1,\}\).*/\2/')

cur_d_r=0; cur_d_w=0
if [ -r /proc/diskstats ]; then
    while read -r major minor dev r_ios r_merges r_sectors r_ticks w_ios w_merges w_sectors remainder; do
        case "$dev" in
            sd*|nvme*|mmcblk*|vd*)
                cur_d_r=$((cur_d_r + r_sectors))
                cur_d_w=$((cur_d_w + w_sectors))
                ;;
        esac
    done < /proc/diskstats
fi
cur_d_r=$((cur_d_r * 512))
cur_d_w=$((cur_d_w * 512))

cur_net_down=0; cur_net_up=0
if [ -r /proc/net/dev ]; then
    NET_LINE=$(grep -E "[[:space:]]$NET_INTRF:" /proc/net/dev)
    if [ -n "$NET_LINE" ]; then
        data_part=$(echo "$NET_LINE" | sed 's/.*://')
        cur_net_down=$(echo "$data_part" | sed 's/^[[:space:]]*\([0-9]\{1,\}\).*/\1/')
        cur_net_up=$(echo "$data_part" | sed 's/^\([[:space:]]*[0-9]\{1,\}\)\{8\}[[:space:]]\{1,\}\([0-9]\{1,\}\).*/\2/')
    fi
fi

now_time=$(date +%s.%N)
old_time=0; old_d_r=0; old_d_w=0; old_n_d=0; old_n_u=0
o_user=0; o_nice=0; o_sys=0; o_idle=0; o_io=0; o_irq=0; o_soft=0
has_time=0; has_dr=0; has_dw=0; has_nd=0; has_nu=0

if [ -r "$CACHE_FILE" ]; then
    ctx=$(cat "$CACHE_FILE")
    t_v=$(echo "$ctx" | sed -n 's/.*"time":\([0-9.]*\).*/\1/p'); if [ -n "$t_v" ]; then old_time=$t_v; has_time=1; fi
    dr_v=$(echo "$ctx" | sed -n 's/.*"d_r":\([0-9]*\).*/\1/p'); if [ -n "$dr_v" ]; then old_d_r=$dr_v; has_dr=1; fi
    dw_v=$(echo "$ctx" | sed -n 's/.*"d_w":\([0-9]*\).*/\1/p'); if [ -n "$dw_v" ]; then old_d_w=$dw_v; has_dw=1; fi
    nd_v=$(echo "$ctx" | sed -n 's/.*"n_d":\([0-9]*\).*/\1/p'); if [ -n "$nd_v" ]; then old_n_d=$nd_v; has_nd=1; fi
    nu_v=$(echo "$ctx" | sed -n 's/.*"n_u":\([0-9]*\).*/\1/p'); if [ -n "$nu_v" ]; then old_n_u=$nu_v; has_nu=1; fi
    cpu_csv=$(echo "$ctx" | sed -n 's/.*"cpu":\[\([0-9,]*\)\].*/\1/p')
    if [ -n "$cpu_csv" ]; then
        o_user=$(echo "$cpu_csv" | cut -d, -f1); o_nice=$(echo "$cpu_csv" | cut -d, -f2)
        o_sys=$(echo "$cpu_csv" | cut -d, -f3); o_idle=$(echo "$cpu_csv" | cut -d, -f4)
        o_io=$(echo "$cpu_csv" | cut -d, -f5); o_irq=$(echo "$cpu_csv" | cut -d, -f6)
        o_soft=$(echo "$cpu_csv" | cut -d, -f7)
    fi
fi

BC_EXEC=$(bc <<EOF
scale=6
time_d = $now_time - $old_time
if (time_d <= 0) time_d = 2.0

old_idle = $o_idle + $o_io
new_idle = $idle + $iowait
old_non_idle = $o_user + $o_nice + $o_sys + $o_irq + $o_soft
new_non_idle = $user + $nice + $system_t + $irq + $softirq

tot_old = old_idle + old_non_idle
tot_new = new_idle + new_non_idle
tot_delta = tot_new - tot_old
idle_delta = new_idle - old_idle

cpu_pcent = 0
if (tot_delta > 0) cpu_pcent = ((tot_delta - idle_delta) / tot_delta) * 100

r_rt = 0; w_rt = 0; d_rt = 0; u_rt = 0
if ($has_dr == 1) r_rt = ($cur_d_r - $old_d_r) / time_d
if ($has_dw == 1) w_rt = ($cur_d_w - $old_d_w) / time_d
if ($has_nd == 1) d_rt = ($cur_net_down - $old_n_d) / time_d
if ($has_nu == 1) u_rt = ($cur_net_up - $old_n_u) / time_d

if (r_rt < 0) r_rt = 0; if (w_rt < 0) w_rt = 0
if (d_rt < 0) d_rt = 0; if (u_rt < 0) u_rt = 0

print cpu_pcent, "\n", r_rt, "\n", w_rt, "\n", d_rt, "\n", u_rt, "\n"
EOF
)

cpu_pcent=$(echo "$BC_EXEC" | sed -n '1p')
r_rt=$(echo "$BC_EXEC" | sed -n '2p')
w_rt=$(echo "$BC_EXEC" | sed -n '3p')
d_rt=$(echo "$BC_EXEC" | sed -n '4p')
u_rt=$(echo "$BC_EXEC" | sed -n '5p')

echo "{\"time\":$now_time,\"cpu\":[$user,$nice,$system_t,$idle,$iowait,$irq,$softirq],\"d_r\":$cur_d_r,\"d_w\":$cur_d_w,\"n_d\":$cur_net_down,\"n_u\":$cur_net_up}" > "$CACHE_FILE"

fmt_rate() {
    val=$1
    if [ "$(echo "$val <= 0" | bc)" -eq 1 ]; then echo "      0B/s"; return; fi
    
    # MB/s (1024^2 = 1048576)
    if [ "$(echo "$val >= 1048576" | bc)" -eq 1 ]; then
        mb=$(echo "scale=2; $val / 1048576" | bc)
        num_str=$(printf "%.2f" "$mb")
    # KB/s (1024)
    elif [ "$(echo "$val >= 1024" | bc)" -eq 1 ]; then
        kb=$(echo "scale=2; $val / 1024" | bc)
        num_str=$(printf "%.2f" "$kb")
        unit="KB/s"
    else
        num_str=$(printf "%.3f" "$val")
        unit="B/s"
    fi

    f_p=$(echo "$num_str" | cut -d'.' -f1)
    b_p=$(echo "$num_str" | cut -d'.' -f2)

    if [ ${#f_p} -gt 3 ]; then
        echo "999999GB/s"
        return
    fi
    
    if [ "$(echo "$val >= 1048576" | bc)" -eq 1 ]; then
        unit="MB/s"
    fi
    # B/s
    padded_fp=$(printf "%3s" "$f_p")
    echo "${padded_fp}.${b_p}${unit}"
}

out_t=$(echo "scale=1; $temp_raw / 1000" | bc)
t_chk=$(echo "$out_t >= 100.0" | bc)
if [ "$t_chk" -eq 1 ]; then out_t="9999°C"; else out_t="${out_t}°C"; fi

ram_used=$(echo "scale=2; ($mem_t - $mem_a) / 1048576" | bc)
ram_tot=$(echo "scale=2; $mem_t / 1048576" | bc)
d_tot_GB=$(echo "scale=2; $d_tot_bytes / 1000000000" | bc)
d_free_GB=$(echo "scale=2; $d_free_bytes / 1000000000" | bc)

f_r=$(fmt_rate "$r_rt"); f_w=$(fmt_rate "$w_rt"); f_d=$(fmt_rate "$d_rt"); f_u=$(fmt_rate "$u_rt")

out_r=$f_r; [ -n "$(echo "$f_r" | grep 999999)" ] && out_r="999999GB/s"
out_w=$f_w; [ -n "$(echo "$f_w" | grep 999999)" ] && out_w="999999GB/s"
out_d=$f_d; [ -n "$(echo "$f_d" | grep 999999)" ] && out_d="999999GB/s"
out_u=$f_u; [ -n "$(echo "$f_u" | grep 999999)" ] && out_u="999999GB/s"

printf " T %s | C %5.1f%% | G %5.1f%% | M %5.2f/%sGB | D %s/%sGB | R %s | W %s | ▼ %s | ▲ %s |" "$out_t" "$cpu_pcent" "$gpu_pcent" "$ram_used" "$ram_tot" "$d_free_GB" "$d_tot_GB" "$out_r" "$out_w" "$out_d" "$out_u"

cat << EOF 1>&2
\`                                       
  SPRM (Simple Panel Resource Monitor)  
           * Shell version *            
                                        
        T = Temperature                 
        C = Total CPU Usage             
        G = Total GPU Usage             
        M = Total Memory Usage          
        D = Total Disk Usage            
        R = Total Disk Read             
        W = Total Disk Write            
        ▼ = Average Download Rate       
        ▲ = Average Upload Rate         
                                        
           click to open btop           
                                       .
EOF
