#!/usr/bin/env python3

import os
import time
import json
import subprocess

NET_INTRF = "wlp3s0"
CACHE_FILE = "/tmp/sprm_cache.json"

def pad(s, length):
    return str(s).rjust(length, ' ')

def fmt(bytesps):
    if bytesps <= 0:
        return "      0B/s"
    units = ["B/s", "KB/s", "MB/s"]
    i = 0
    v = float(bytesps)
    while v >= 1024 and i < len(units) - 1:
        v /= 1024
        i += 1
    if i == 0:
        num_str = f"{v:.3f}"
    else:
        num_str = f"{v:.2f}"

    parts = num_str.split('.')
    f_p = parts[0]
    b_p = parts[1]
    if len(f_p) > 3:
        return "999999GB/s"
    return f"{pad(f_p, 3)}.{b_p}{units[i]}"

def get_system_data():
    try:
        temp_out = subprocess.check_output("sensors 2>/dev/null", shell=True).decode()
        temp_v = 0.0
        i = 0
        for ln in temp_out.split('\n'):
            if 'Tctl' in ln or 'Tdie' in ln or 'Edge' in ln or 'Core' in ln:
                parts = ln.split()
                for p in parts:
                    if '+' in p and '°C' in p:
                        val = float(p.replace('+', '').replace('°C', ''))
                        temp_v += val
                        i += 1
                        break
        temp_val = temp_v / i if i > 0 else 0.0
    except:
        temp_val = 0.0

    try:
        with open("/proc/stat", "r") as f:
            for ln in f:
                if ln.startswith("cpu "):
                    parts = [int(x) for x in ln.split()[1:8]]
                    break
    except:
        parts = [0, 0, 0, 0, 0, 0, 0]

    try:
        with open("/sys/class/drm/card0/device/gpu_busy_percent", "r") as f:
            gpu_val = float(f.read().strip())
    except:
        gpu_val = 0.0

    try:
        mem_t, mem_a = 0, 0
        with open("/proc/meminfo", "r") as f:
            for ln in f:
                if "MemTotal" in ln:
                    mem_t = int(ln.split()[1])
                elif "MemAvailable" in ln:
                    mem_a = int(ln.split()[1])
        ram_used = (mem_t - mem_a) / 1024 / 1024
        ram_tot = mem_t / 1024 / 1024
    except:
        ram_used, ram_tot = 0.0, 0.0

    try:
        st = os.statvfs('/')
        d_tot = st.f_blocks * st.f_frsize
        d_avail = st.f_bavail * st.f_frsize
        d_free_GB = d_avail / 1e9
        d_tot_GB = d_tot / 1e9
    except:
        d_free_GB, d_tot_GB = 0.0, 0.0

    try:
        r_io, w_io = 0, 0
        with open("/proc/diskstats", "r") as f:
            for ln in f:
                p = ln.split()
                if any(x in p[2] for x in ['sd', 'nvme']):
                    r_io += int(p[5])
                    w_io += int(p[9])
        cur_d_r = r_io * 512
        cur_d_w = w_io * 512
    except:
        cur_d_r, cur_d_w = 0, 0

    try:
        cur_net_down, cur_net_up = 0, 0
        with open("/proc/net/dev", "r") as f:
            for ln in f:
                if NET_INTRF in ln:
                    p = ln.split()
                    cur_net_down = int(p[1])
                    cur_net_up = int(p[9])
                    break
    except:
        cur_net_down, cur_net_up = 0, 0

    return temp_val, parts, gpu_val, ram_used, ram_tot, d_free_GB, d_tot_GB, cur_d_r, cur_d_w, cur_net_down, cur_net_up

def main():
    now_time = time.monotonic()
    temp_val, cpu_parts, gpu_val, ram_used, ram_tot, d_free_GB, d_tot_GB, cur_d_r, cur_d_w, cur_net_down, cur_net_up = get_system_data()

    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, "r") as f:
                old = json.load(f)
        except:
            old = {}
    else:
        old = {}

    lst_time = old.get("time", now_time - 2.0)
    time_d = now_time - lst_time
    if time_d <= 0:
        time_d = 2.0

    old_cpu = old.get("cpu", [0,0,0,0,0,0,0])
    user, nice, system, idle, iowait, irq, softirq = cpu_parts
    old_idle = old_cpu[3] + old_cpu[4]
    new_idle = idle + iowait
    old_non_idle = old_cpu[0] + old_cpu[1] + old_cpu[2] + old_cpu[5] + old_cpu[6]
    new_non_idle = user + nice + system + irq + softirq
    tot_old = old_idle + old_non_idle
    tot_new = new_idle + new_non_idle
    tot_delta = tot_new - tot_old
    idle_delta = new_idle - old_idle

    cpu_pcent = 0.0
    if tot_delta > 0:
        cpu_pcent = ((tot_delta - idle_delta) / tot_delta) * 100
    cpu_str = f"{cpu_pcent:.1f}"
    cpu_fmt = pad(cpu_str, 4)

    r_rt = (cur_d_r - old.get("d_r", cur_d_r)) / time_d if "d_r" in old else 0
    w_rt = (cur_d_w - old.get("d_w", cur_d_w)) / time_d if "d_w" in old else 0
    d_rt = (cur_net_down - old.get("n_d", cur_net_down)) / time_d if "n_d" in old else 0
    u_rt = (cur_net_up - old.get("n_u", cur_net_up)) / time_d if "n_u" in old else 0

    r_rt = max(0.0, r_rt)
    w_rt = max(0.0, w_rt)
    d_rt = max(0.0, d_rt)
    u_rt = max(0.0, u_rt)

    with open(CACHE_FILE, "w") as f:
        json.dump({"time": now_time, "cpu": cpu_parts, "d_r": cur_d_r, "d_w": cur_d_w, "n_d": cur_net_down, "n_u": cur_net_up}, f)

    temp_str = "9999" if temp_val >= 100.0 else f"{temp_val:.1f}"
    gpu_fmt = pad(f"{gpu_val:.1f}", 4)
    ram_used_str = pad(f"{ram_used:.2f}", 5)
    ram_tot_str = f"{ram_tot:.2f}"
    d_free_str = f"{d_free_GB:.2f}"
    d_tot_str = f"{d_tot_GB:.2f}"

    f_r = fmt(r_rt)
    f_w = fmt(w_rt)
    f_d = fmt(d_rt)
    f_u = fmt(u_rt)

    out_t = "9999°C" if temp_str == "9999" else f"{temp_str}°C"
    out_r = "999999GB/s" if "999999" in f_r else f_r
    out_w = "999999GB/s" if "999999" in f_w else f_w
    out_d = "999999GB/s" if "999999" in f_d else f_d
    out_u = "999999GB/s" if "999999" in f_u else f_u

    rr = f" T {out_t} | C {cpu_fmt}% | G {gpu_fmt}% | M {ram_used_str}/{ram_tot_str}GB | D {d_free_str}/{d_tot_str}GB | R {out_r} | W {out_w} | ▼ {out_d} | ▲ {out_u} |"
    print(rr)

if __name__ == "__main__":
    main()
