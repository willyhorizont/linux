#!/usr/bin/env python3

import os
import sys
import time
import json
import re

CACHE_FILE = "/tmp/sprm-cache-py.json"


def get_active_net_interf():
    net_interf = "lo"
    
    if os.path.exists("/proc/net/route"):
        try:
            with open("/proc/net/route", "r") as f:
                next(f)
                for ln in f:
                    parts = ln.split()
                    if len(parts) > 2:
                        if parts[1] == "00000000" and parts[0] != "lo":
                            net_interf = parts[0]
                            break
        except:
            pass

    if net_interf == "lo" and os.path.exists("/proc/net/dev"):
        try:
            with open("/proc/net/dev", "r") as f:
                for ln in f:
                    if ":" in ln:
                        candidate = ln.split(":")[0].strip()
                        if not re.compile(r"^(lo|sit|docker|veth|br-|virbr)").match(candidate):
                            net_interf = candidate
                            break
        except:
            pass
            
    return net_interf


def pad(s, length):
    return str(s).rjust(length, ' ')


def fmt(bytesps):
    if bytesps <= 0:
        return "      0", "B/s"
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
        return "999999", "GB/s"
    return f"{pad(f_p, 3)}.{b_p}", units[i]


def get_system_data():
    net_intrf = get_active_net_interf()
    temp_val = 0.0
    for zone in range(6):
        t_path = f"/sys/class/thermal/thermal_zone{zone}/temp"
        if os.path.exists(t_path):
            try:
                with open(t_path, "r") as f:
                    t = float(f.read().strip())
                    if t > 0:
                        temp_val = t / 1000.0
                        break
            except:
                pass

    try:
        with open("/proc/stat", "r") as f:
            for ln in f:
                if ln.startswith("cpu "):
                    parts = [int(x) for x in ln.split()[1:8]]
                    break
    except:
        parts = [0, 0, 0, 0, 0, 0, 0]

    gpu_val = 0.0
    if os.path.exists("/sys/class/drm/card0/device/gpu_busy_percent"): # AMD
        try:
            with open("/sys/class/drm/card0/device/gpu_busy_percent", "r") as f:
                gpu_val = float(f.read().strip())
        except:
            pass
    elif os.path.exists("/sys/class/drm/card0/gt_act_freq_mhz") and os.path.exists("/sys/class/drm/card0/gt_max_freq_mhz"): # Intel
        try:
            with open("/sys/class/drm/card0/gt_act_freq_mhz", "r") as f:
                act = float(f.read().strip())
            with open("/sys/class/drm/card0/gt_max_freq_mhz", "r") as f:
                max_f = float(f.read().strip())
            gpu_val = (act / max_f) * 100.0 if max_f > 0 else 0.0
        except:
            pass

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
                if len(p) > 9 and re.compile(r"^(sd[a-z]|nvme\d+n\d+|mmcblk\d+|vd[a-z])$").match(p[2]):
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
                if net_intrf in ln:
                    p = ln.split()
                    if ":" in p[0]:
                        cur_net_down = int(p[1])
                        cur_net_up = int(p[9])
                    else:
                        cur_net_down = int(p[1])
                        cur_net_up = int(p[9])
                    break
    except:
        cur_net_down, cur_net_up = 0, 0

    return temp_val, parts, gpu_val, ram_used, ram_tot, d_free_GB, d_tot_GB, cur_d_r, cur_d_w, cur_net_down, cur_net_up


def main():
    pref = " "
    suff = " "
    sep = " | "
    use_pango = False

    args = sys.argv[1:]
    i = 0
    while i < len(args):
        if args[i] == "--pref" and i + 1 < len(args):
            pref = args[i+1]
            i += 2
        elif args[i] == "--suff" and i + 1 < len(args):
            suff = args[i+1]
            i += 2
        elif args[i] == "--sep" and i + 1 < len(args):
            sep = args[i+1]
            i += 2
        elif args[i] == "--pango":
            use_pango = True
            i += 1
        else:
            i += 1

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
    cpu_fmt = pad(cpu_str, 5)

    r_rt = (cur_d_r - old.get("d_r", cur_d_r)) / time_d if "d_r" in old else 0
    w_rt = (cur_d_w - old.get("d_w", cur_d_w)) / time_d if "d_w" in old else 0
    d_rt = (cur_net_down - old.get("n_d", cur_net_down)) / time_d if "n_d" in old else 0
    u_rt = (cur_net_up - old.get("n_u", cur_net_up)) / time_d if "n_u" in old else 0

    r_rt = max(0.0, r_rt)
    w_rt = max(0.0, w_rt)
    d_rt = max(0.0, d_rt)
    u_rt = max(0.0, u_rt)

    try:
        with open(CACHE_FILE, "w") as f:
            json.dump({"time": now_time, "cpu": cpu_parts, "d_r": cur_d_r, "d_w": cur_d_w, "n_d": cur_net_down, "n_u": cur_net_up}, f)
    except:
        pass

    temp_str = "9999" if temp_val >= 100.0 else f"{temp_val:.1f}"
    gpu_fmt = pad(f"{gpu_val:.1f}", 5)
    ram_used_str = pad(f"{ram_used:.2f}", 5)
    ram_tot_str = f"{ram_tot:.2f}"
    d_free_str = f"{d_free_GB:.2f}"
    d_tot_str = f"{d_tot_GB:.2f}"

    f_r_val, f_r_unit = fmt(r_rt)
    f_w_val, f_w_unit = fmt(w_rt)
    f_d_val, f_d_unit = fmt(d_rt)
    f_u_val, f_u_unit = fmt(u_rt)

    out_t_val = "9999" if temp_str == "9999" else temp_str
    out_t_unit = "°C"
    
    out_r_val = "999999" if "999999" in f_r_val else f_r_val
    out_r_unit = "GB/s" if "999999" in f_r_val else f_r_unit
    
    out_w_val = "999999" if "999999" in f_w_val else f_w_val
    out_w_unit = "GB/s" if "999999" in f_w_val else f_w_unit
    
    out_d_val = "999999" if "999999" in f_d_val else f_d_val
    out_d_unit = "GB/s" if "999999" in f_d_val else f_d_unit
    
    out_u_val = "999999" if "999999" in f_u_val else f_u_val
    out_u_unit = "GB/s" if "999999" in f_u_val else f_u_unit

    blocks = [
        {"key": "T ", "val": out_t_val, "unit": out_t_unit},
        {"key": "C ", "val": cpu_fmt, "unit": "%"},
        {"key": "G ", "val": gpu_fmt, "unit": "%"},
        {"key": "M ", "val": f"{ram_used_str}/{ram_tot_str}", "unit": "GB"},
        {"key": "D ", "val": f"{d_free_str}/{d_tot_str}", "unit": "GB"},
        {"key": "R ", "val": out_r_val, "unit": out_r_unit},
        {"key": "W ", "val": out_w_val, "unit": out_w_unit},
        {"key": "▼ ", "val": out_d_val, "unit": out_d_unit},
        {"key": "▲ ", "val": out_u_val, "unit": out_u_unit}
    ]

    out_str = ""
    if use_pango:
        if pref:
            out_str += f"<span background='#000000' foreground='#00ADD8'>{pref}</span>"
        for idx, b in enumerate(blocks):
            out_str += f"<span background='#000000' foreground='#FF1493'>{b['key']}</span>"
            out_str += f"<span background='#000000' foreground='#CCFF00'>{b['val']}</span>"
            out_str += f"<span background='#000000' foreground='#FF1493'>{b['unit']}</span>"
            if idx < len(blocks) - 1:
                out_str += f"<span background='#000000' foreground='#00ADD8'>{sep}</span>"
        if suff:
            out_str += f"<span background='#000000' foreground='#00ADD8'>{suff}</span>"
    else:
        out_str += pref
        for idx, b in enumerate(blocks):
            out_str += f"{b['key']}{b['val']}{b['unit']}"
            if idx < len(blocks) - 1:
                out_str += sep
        out_str += suff
            
    print(out_str, flush=True)

    print("""SPRM (Suckless Panel Resource Monitor) Python version
T = Temperature
C = Total CPU Usage
G = Total GPU Usage
M = Total Memory Usage
D = Total Disk Usage
R = Total Disk Read
W = Total Disk Write
▼ = Average Download Rate
▲ = Average Upload Rate
click to open btop""", file=sys.stderr)


if __name__ == "__main__":
    main()
