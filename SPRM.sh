#!/bin/bash

NET_INTRF="wlp3s0"
CACHE_FILE="/tmp/sprm_bash_cache.txt"

_pad() {
    printf "%*s" "$2" "$1"
}

_fmt() {
    local bytes=$1
    if (( $(echo "$bytes <= 0" | bc -l) )); then
        echo "      0B/s"
        return
    fi

    local units=("B/s" "KB/s" "MB/s")
    local i=0
    local v=$bytes

    while (( $(echo "$v >= 1024" | bc -l) )) && [ $i -lt 2 ]; do
        v=$(echo "$v / 1024" | bc -l)
        i=$((i + 1))
    done

    local num_str=""
    if [ $i -eq 0 ]; then
        num_str=$(printf "%.3f" "$v")
    else
        num_str=$(printf "%.2f" "$v")
    fi

    local f_p=$(echo "$num_str" | cut -d'.' -f1)
    local b_p=$(echo "$num_str" | cut -d'.' -f2)

    if [ ${#f_p} -gt 3 ]; then
        echo "999999GB/s"
        return
    fi

    local padded_fp=$(_pad "$f_p" 3)
    echo "${padded_fp}.${b_p}${units[$i]}"
}

TEMP=$(sensors 2>/dev/null | awk '/Tctl|Tdie|Edge|Core/ {for(i=1;i<=NF;i++) if($i ~ /\+/ && $i ~ /°C/) {gsub(/[+°C]/,"",$i); print $i; exit}}')
[ -z "$TEMP" ] && TEMP="0.0"

CPU_RAW=$(awk '/^cpu / {print $2" "$3" "$4" "$5" "$6" "$7" "$8}' /proc/stat)
GPU=$(cat /sys/class/drm/card0/device/gpu_busy_percent 2>/dev/null || echo "0")
RAM=$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {printf "%.2f/%.2f", (t-a)/1024/1024, t/1024/1024}' /proc/meminfo)
DISK=$(df -B1 / | awk 'NR==2 {printf "%s/%s", $2, $4}')
DISK_IO=$(awk '/ss/ || /sd/ || /nvme/ {r+=$6; w+=$10} END {print r" "w}' /proc/diskstats)
NET_IO=$(awk -F: "/$NET_INTRF/ {print \$2}" /proc/net/dev | awk '{print $1" "$9}')
[ -z "$NET_IO" ] && NET_IO="0 0"

NOW_TIME=$(date +%s.%N)

if [ -f "$CACHE_FILE" ]; then
    source "$CACHE_FILE"
else
    LST_TIME=$(echo "$NOW_TIME - 2.0" | bc -l)
    LST_CPU="$CPU_RAW"
    LST_D_R=0; LST_D_W=0; LST_N_D=0; LST_N_U=0
fi

TIME_D=$(echo "$NOW_TIME - $LST_TIME" | bc -l)
if (( $(echo "$TIME_D <= 0" | bc -l) )); then
    TIME_D=2.0
fi

read -r user nice system idle iowait irq softirq <<< "$CPU_RAW"
read -r l_user l_nice l_system l_idle l_iowait l_ir l_softirq <<< "$LST_CPU"

OLD_IDLE=$((l_idle + l_iowait))
NEW_IDLE=$((idle + iowait))
OLD_NON_IDLE=$((l_user + l_nice + l_system + l_ir + l_softirq))
NEW_NON_IDLE=$((user + nice + system + irq + softirq))

TOT_OLD=$((OLD_IDLE + OLD_NON_IDLE))
TOT_NEW=$((NEW_IDLE + NEW_NON_IDLE))
TOT_DELTA=$((TOT_NEW - TOT_OLD))
IDLE_DELTA=$((NEW_IDLE - OLD_IDLE))

CPU_PCENT="0.0"
if [ $TOT_DELTA -gt 0 ]; then
    CPU_PCENT=$(echo "scale=2; (($TOT_DELTA - $IDLE_DELTA) / $TOT_DELTA) * 100" | bc -l)
fi
CPU_STR=$(printf "%.1f" "$CPU_PCENT")
CPU_FMT=$(_pad "$CPU_STR" 4)

read -r cur_r cur_w <<< "$DISK_IO"
cur_d_r=$((cur_r * 512))
cur_d_w=$((cur_w * 512))

read -r cur_net_down cur_net_up <<< "$NET_IO"

R_RT=$(echo "scale=4; ($cur_d_r - $LST_D_R) / $TIME_D" | bc -l)
W_RT=$(echo "scale=4; ($cur_d_w - $LST_D_W) / $TIME_D" | bc -l)
D_RT=$(echo "scale=4; ($cur_net_down - $LST_N_D) / $TIME_D" | bc -l)
U_RT=$(echo "scale=4; ($cur_net_up - $LST_N_U) / $TIME_D" | bc -l)

(( $(echo "$R_RT < 0" | bc -l) )) && R_RT=0
(( $(echo "$W_RT < 0" | bc -l) )) && W_RT=0
(( $(echo "$D_RT < 0" | bc -l) )) && D_RT=0
(( $(echo "$U_RT < 0" | bc -l) )) && U_RT=0

cat << EOF > "$CACHE_FILE"
LST_TIME=$NOW_TIME
LST_CPU="$CPU_RAW"
LST_D_R=$cur_d_r
LST_D_W=$cur_d_w
LST_N_D=$cur_net_down
LST_N_U=$cur_net_up
EOF

if (( $(echo "$TEMP >= 100.0" | bc -l) )); then
    TEMP_STR="9999"
else
    TEMP_STR=$(printf "%.1f" "$TEMP")
fi

GPU_FMT=$(_pad "$(printf "%.1f" "$GPU")" 4)

read -r r_used r_tot <<< $(echo "$RAM" | tr '/' ' ')
RAM_USED_STR=$(_pad "$(printf "%.2f" "$r_used")" 5)
RAM_TOT_STR=$(printf "%.2f" "$r_tot")

read -r d_tot_b d_avail_b <<< $(echo "$DISK" | tr '/' ' ')
D_FREE_GB=$(echo "scale=2; $d_avail_b / 1000000000" | bc -l)
D_TOT_GB=$(echo "scale=2; $d_tot_b / 1000000000" | bc -l)
D_FREE_STR=$(printf "%.2f" "$D_FREE_GB")
D_TOT_STR=$(printf "%.2f" "$D_TOT_GB")

F_R=$(_fmt "$R_RT")
F_W=$(_fmt "$W_RT")
F_D=$(_fmt "$D_RT")
F_U=$(_fmt "$U_RT")

OUT_T="${TEMP_STR}°C"
[ "$TEMP_STR" = "9999" ] && OUT_T="9999°C"

OUT_R=$F_R; [[ "$F_R" == *"999999"* ]] && OUT_R="999999GB/s"
OUT_W=$F_W; [[ "$F_W" == *"999999"* ]] && OUT_W="999999GB/s"
OUT_D=$F_D; [[ "$F_D" == *"999999"* ]] && OUT_D="999999GB/s"
OUT_U=$F_U; [[ "$F_U" == *"999999"* ]] && OUT_U="999999GB/s"

echo " T $OUT_T | C $CPU_FMT% | G $GPU_FMT% | M $RAM_USED_STR/${RAM_TOT_STR}GB | D $D_FREE_STR/${D_TOT_STR}GB | R $OUT_R | W $OUT_W | ▼ $OUT_D | ▲ $OUT_U |"
