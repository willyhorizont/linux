#!/bin/sh

CACHE_FILE="/tmp/sprm-cache-sh.json"

pref=" "
suff=" "
sep=" | "
use_pango=0

while [ $# -gt 0 ]; do
    case "$1" in
        --pref) pref="$2"; shift 2 ;;
        --suff) suff="$2"; shift 2 ;;
        --sep)  sep="$2";  shift 2 ;;
        --pango) use_pango=1; shift ;;
        *) shift ;;
    esac
done

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
    NET_DATA=$(awk -v iface="$NET_INTRF" '$0 ~ iface":" {sub(/^.*:/, ""); print $1, $9}' /proc/net/dev)
    if [ -n "$NET_DATA" ]; then
        cur_net_down=$(echo "$NET_DATA" | cut -d' ' -f1)
        cur_net_up=$(echo "$NET_DATA" | cut -d' ' -f2)
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

fmt_rate_parts() {
    val=$1
    if [ "$(echo "$val <= 0" | bc)" -eq 1 ]; then echo "      0:B/s"; return; fi
    
    # MB/s (1024^2 = 1048576)
    if [ "$(echo "$val >= 1048576" | bc)" -eq 1 ]; then
        mb=$(echo "scale=2; $val / 1048576" | bc)
        num_str=$(printf "%.2f" "$mb")
        unit="MB/s"
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
        echo "999999:GB/s"
        return
    fi
    
    # B/s
    padded_fp=$(printf "%3s" "$f_p")
    echo "${padded_fp}.${b_p}:${unit}"
}

out_t_val=$(echo "scale=1; $temp_raw / 1000" | bc)
t_chk=$(echo "$out_t_val >= 100.0" | bc)
if [ "$t_chk" -eq 1 ]; then out_t_val="9999"; fi
out_t_unit="°C"

cpu_fmt=$(printf "%5.1f" "$cpu_pcent")
gpu_fmt=$(printf "%5.1f" "$gpu_pcent")

ram_used=$(echo "scale=2; ($mem_t - $mem_a) / 1048576" | bc)
ram_tot=$(echo "scale=2; $mem_t / 1048576" | bc)
ram_used_fmt=$(printf "%5.2f" "$ram_used")
ram_tot_fmt=$(printf "%.2f" "$ram_tot")
ram_val="${ram_used_fmt}/${ram_tot_fmt}"

d_tot_GB=$(echo "scale=2; $d_tot_bytes / 1000000000" | bc)
d_free_GB=$(echo "scale=2; $d_free_bytes / 1000000000" | bc)
d_free_fmt=$(printf "%.2f" "$d_free_GB")
d_tot_fmt=$(printf "%.2f" "$d_tot_GB")
disk_val="${d_free_fmt}/${d_tot_fmt}"

f_r=$(fmt_rate_parts "$r_rt"); f_w=$(fmt_rate_parts "$w_rt"); f_d=$(fmt_rate_parts "$d_rt"); f_u=$(fmt_rate_parts "$u_rt")

r_val=$(echo "$f_r" | cut -d':' -f1); r_unit=$(echo "$f_r" | cut -d':' -f2)
w_val=$(echo "$f_w" | cut -d':' -f1); w_unit=$(echo "$f_w" | cut -d':' -f2)
d_val=$(echo "$f_d" | cut -d':' -f1); d_unit=$(echo "$f_d" | cut -d':' -f2)
u_val=$(echo "$f_u" | cut -d':' -f1); u_unit=$(echo "$f_u" | cut -d':' -f2)

k0="T "; v0="$out_t_val"; u0="$out_t_unit"
k1="C "; v1="$cpu_fmt";   u1="%"
k2="G "; v2="$gpu_fmt";   u2="%"
k3="M "; v3="$ram_val";   u3="GB"
k4="D "; v4="$disk_val";  u4="GB"
k5="R "; v5="$r_val";     u5="$r_unit"
k6="W "; v6="$w_val";     u6="$w_unit"
k7="▼ "; v7="$d_val";     u7="$d_unit"
k8="▲ "; v8="$u_val";     u8="$u_unit"

out_string=""
if [ "$use_pango" -eq 1 ]; then
    [ -n "$pref" ] && out_string="<span background='#000000' foreground='#00ADD8'>$pref</span>"
    out_string="${out_string}<span background='#000000' foreground='#FF1493'>$k0</span><span background='#000000' foreground='#CCFF00'>$v0</span><span background='#000000' foreground='#FF1493'>$u0</span><span background='#000000' foreground='#00ADD8'>$sep</span>"
    out_string="${out_string}<span background='#000000' foreground='#FF1493'>$k1</span><span background='#000000' foreground='#CCFF00'>$v1</span><span background='#000000' foreground='#FF1493'>$u1</span><span background='#000000' foreground='#00ADD8'>$sep</span>"
    out_string="${out_string}<span background='#000000' foreground='#FF1493'>$k2</span><span background='#000000' foreground='#CCFF00'>$v2</span><span background='#000000' foreground='#FF1493'>$u2</span><span background='#000000' foreground='#00ADD8'>$sep</span>"
    out_string="${out_string}<span background='#000000' foreground='#FF1493'>$k3</span><span background='#000000' foreground='#CCFF00'>$v3</span><span background='#000000' foreground='#FF1493'>$u3</span><span background='#000000' foreground='#00ADD8'>$sep</span>"
    out_string="${out_string}<span background='#000000' foreground='#FF1493'>$k4</span><span background='#000000' foreground='#CCFF00'>$v4</span><span background='#000000' foreground='#FF1493'>$u4</span><span background='#000000' foreground='#00ADD8'>$sep</span>"
    out_string="${out_string}<span background='#000000' foreground='#FF1493'>$k5</span><span background='#000000' foreground='#CCFF00'>$v5</span><span background='#000000' foreground='#FF1493'>$u5</span><span background='#000000' foreground='#00ADD8'>$sep</span>"
    out_string="${out_string}<span background='#000000' foreground='#FF1493'>$k6</span><span background='#000000' foreground='#CCFF00'>$v6</span><span background='#000000' foreground='#FF1493'>$u6</span><span background='#000000' foreground='#00ADD8'>$sep</span>"
    out_string="${out_string}<span background='#000000' foreground='#FF1493'>$k7</span><span background='#000000' foreground='#CCFF00'>$v7</span><span background='#000000' foreground='#FF1493'>$u7</span><span background='#000000' foreground='#00ADD8'>$sep</span>"
    out_string="${out_string}<span background='#000000' foreground='#FF1493'>$k8</span><span background='#000000' foreground='#CCFF00'>$v8</span><span background='#000000' foreground='#FF1493'>$u8</span>"
    [ -n "$suff" ] && out_string="${out_string}<span background='#000000' foreground='#00ADD8'>$suff</span>"
else
    out_string="${pref}${k0}${v0}${u0}${sep}${k1}${v1}${u1}${sep}${k2}${v2}${u2}${sep}${k3}${v3}${u3}${sep}${k4}${disk_val}${u4}${sep}${k5}${v5}${u5}${sep}${k6}${v6}${u6}${sep}${k7}${v7}${u7}${sep}${k8}${v8}${u8}${suff}"
fi
printf "%s\n" "$out_string"
cat << EOF 1>&2
SPRM (Suckless Panel Resource Monitor) POSIX Shell version
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
EOF
