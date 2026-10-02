#define _POSIX_C_SOURCE 199309L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <ctype.h>
#include <sys/stat.h>
#include <sys/statvfs.h>

#define CACHE_FILE "/tmp/sprm-c-cache.json"

void pad(const char *str, int len, char *out) {
    sprintf(out, "%*s", len, str);
}

void fmt(double bytesps, char *out) {
    if (bytesps <= 0) {
        strcpy(out, "      0B/s");
        return;
    }
    const char *units[] = {"B/s", "KB/s", "MB/s"};
    int i = 0;
    double v = bytesps;
    while (v >= 1024 && i < 2) {
        v /= 1024;
        i++;
    }
    char num_str[64];
    if (i == 0) sprintf(num_str, "%.3f", v);
    else sprintf(num_str, "%.2f", v);
    
    char f_p[64] = {0};
    char b_p[64] = {0};
    char *dot = strchr(num_str, '.');
    if (dot) {
        *dot = '\0';
        strcpy(f_p, num_str);
        strcpy(b_p, dot + 1);
    } else {
        strcpy(f_p, num_str);
        strcpy(b_p, "00");
    }
    if (strlen(f_p) > 3) {
        strcpy(out, "999999GB/s");
        return;
    }
    char padded_f[64];
    pad(f_p, 3, padded_f);
    sprintf(out, "%s.%s%s", padded_f, b_p, units[i]);
}

int main() {
    char NET_INTRF[64];
    strcpy(NET_INTRF, "lo");
    FILE *fh = fopen("/proc/net/route", "r");
    if (fh) {
        char ln[256];
        if (fgets(ln, sizeof(ln), fh)) { // skip header
            while (fgets(ln, sizeof(ln), fh)) {
                char iface[64], dest[64];
                if (sscanf(ln, "%63s %63s", iface, dest) >= 2) {
                    if (strcmp(dest, "00000000") == 0 && strcmp(iface, "lo") != 0) {
                        strcpy(NET_INTRF, iface);
                        break;
                    }
                }
            }
        }
        fclose(fh);
    }
    if (strcmp(NET_INTRF, "lo") == 0) {
        fh = fopen("/proc/net/dev", "r");
        if (fh) {
            char ln[256];
            while (fgets(ln, sizeof(ln), fh)) {
                char candidate[64];
                char *colon = strchr(ln, ':');
                if (colon) {
                    char *start = ln;
                    while (isspace((unsigned char)*start)) start++;
                    size_t len = colon - start;
                    if (len < 64) {
                        strncpy(candidate, start, len);
                        candidate[len] = '\0';
                        if (strcmp(candidate, "lo") != 0 && strncmp(candidate, "sit", 3) != 0 && strncmp(candidate, "docker", 6) != 0 && strncmp(candidate, "veth", 4) != 0 && strncmp(candidate, "br-", 3) != 0 && strncmp(candidate, "virbr", 5) != 0) {
                            strcpy(NET_INTRF, candidate);
                            break;
                        }
                    }
                }
            }
            fclose(fh);
        }
    }
    double temp = 0.0;
    for (int zone = 0; zone <= 5; zone++) {
        char path[128];
        sprintf(path, "/sys/class/thermal/thermal_zone%d/temp", zone);
        fh = fopen(path, "r");
        if (fh) {
            char t_buf[64];
            if (fgets(t_buf, sizeof(t_buf), fh)) {
                double t = atof(t_buf);
                if (t > 0) {
                    temp = t / 1000.0;
                    fclose(fh);
                    break;
                }
            }
            fclose(fh);
        }
    }
    unsigned long long cpu_parts[7] = {0};
    fh = fopen("/proc/stat", "r");
    if (fh) {
        char ln[1024];
        while (fgets(ln, sizeof(ln), fh)) {
            if (strncmp(ln, "cpu ", 4) == 0) {
                sscanf(ln, "cpu %llu %llu %llu %llu %llu %llu %llu", &cpu_parts[0], &cpu_parts[1], &cpu_parts[2], &cpu_parts[3], &cpu_parts[4], &cpu_parts[5], &cpu_parts[6]);
                break;
            }
        }
        fclose(fh);
    }
    double gpu = 0.0;
    struct stat st;
    // AMD
    if (stat("/sys/class/drm/card0/device/gpu_busy_percent", &st) == 0) {
        fh = fopen("/sys/class/drm/card0/device/gpu_busy_percent", "r");
        if (fh) {
            char buf[64];
            if (fgets(buf, sizeof(buf), fh)) {
                gpu = atof(buf);
            }
            fclose(fh);
        }
    // Intel
    } else if (stat("/sys/class/drm/card0/gt_act_freq_mhz", &st) == 0 && stat("/sys/class/drm/card0/gt_max_freq_mhz", &st) == 0) {
        double act = 0.0, max_f = 1.0;
        fh = fopen("/sys/class/drm/card0/gt_act_freq_mhz", "r");
        if (fh) {
            char buf[64];
            if (fgets(buf, sizeof(buf), fh)) act = atof(buf);
            fclose(fh);
        }
        fh = fopen("/sys/class/drm/card0/gt_max_freq_mhz", "r");
        if (fh) {
            char buf[64];
            if (fgets(buf, sizeof(buf), fh)) max_f = atof(buf);
            fclose(fh);
        }
        gpu = (max_f > 0.0) ? (act / max_f) * 100.0 : 0.0;
    }
    unsigned long long mem_t = 0, mem_a = 0;
    fh = fopen("/proc/meminfo", "r");
    if (fh) {
        char ln[256];
        while (fgets(ln, sizeof(ln), fh)) {
            unsigned long long val;
            if (sscanf(ln, "MemTotal: %llu", &val) == 1) mem_t = val;
            else if (sscanf(ln, "MemAvailable: %llu", &val) == 1) mem_a = val;
        }
        fclose(fh);
    }
    double ram_used = (double)(mem_t - mem_a) / 1024.0 / 1024.0;
    double ram_tot = (double)mem_t / 1024.0 / 1024.0;
    double d_free_GB = 0.0, d_tot_GB = 0.0;
    struct statvfs vfs;
    if (statvfs("/", &vfs) == 0) {
        d_tot_GB = (double)(vfs.f_blocks * vfs.f_frsize) / 1e9;
        d_free_GB = (double)(vfs.f_bavail * vfs.f_frsize) / 1e9;
    }
    unsigned long long cur_d_r = 0, cur_d_w = 0;
    fh = fopen("/proc/diskstats", "r");
    if (fh) {
        char ln[512];
        while (fgets(ln, sizeof(ln), fh)) {
            char p[11][64];
            int match = sscanf(ln, "%63s %63s %63s %63s %63s %63s %63s %63s %63s %63s %63s", p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], p[10]);
            if (match >= 10) {
                char *dev = p[2];
                int is_target = 0;
                if (strncmp(dev, "sd", 2) == 0 && strlen(dev) == 3 && dev[2] >= 'a' && dev[2] <= 'z') is_target = 1;
                else if (strncmp(dev, "vd", 2) == 0 && strlen(dev) == 3 && dev[2] >= 'a' && dev[2] <= 'z') is_target = 1;
                else if (strncmp(dev, "nvme", 4) == 0 && strchr(dev, 'n') != NULL) is_target = 1;
                else if (strncmp(dev, "mmcblk", 6) == 0) is_target = 1;
                if (is_target) {
                    cur_d_r += strtoull(p[5], NULL, 10);
                    cur_d_w += strtoull(p[9], NULL, 10);
                }
            }
        }
        fclose(fh);
    }
    cur_d_r *= 512;
    cur_d_w *= 512;
    unsigned long long cur_net_down = 0, cur_net_up = 0;
    fh = fopen("/proc/net/dev", "r");
    if (fh) {
        char ln[512];
        while (fgets(ln, sizeof(ln), fh)) {
            if (strstr(ln, NET_INTRF)) {
                char *colon = strchr(ln, ':');
                if (colon) {
                    char *data = colon + 1;
                    char p[10][64];
                    int m = sscanf(data, "%63s %63s %63s %63s %63s %63s %63s %63s %63s %63s", p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9]);
                    if (m >= 9) {
                        cur_net_down = strtoull(p[0], NULL, 10);
                        cur_net_up = strtoull(p[8], NULL, 10);
                    }
                }
                break;
            }
        }
        fclose(fh);
    }
    struct timespec spec;
    clock_gettime(CLOCK_REALTIME, &spec);
    double now_time = spec.tv_sec + (double)spec.tv_nsec / 1e9;
    double old_time = 0.0;
    unsigned long long old_d_r = 0, old_d_w = 0, old_n_d = 0, old_n_u = 0;
    unsigned long long old_cpu[7] = {0};
    int has_time = 0, has_dr = 0, has_dw = 0, has_nd = 0, has_nu = 0;
    if (access(CACHE_FILE, F_OK) == 0) {
        fh = fopen(CACHE_FILE, "r");
        if (fh) {
            char ctx[1024];
            if (fgets(ctx, sizeof(ctx), fh)) {
                char *p;
                if ((p = strstr(ctx, "\"time\":"))) { old_time = strtod(p + 7, NULL); has_time = 1; }
                if ((p = strstr(ctx, "\"d_r\":"))) { old_d_r = strtoull(p + 6, NULL, 10); has_dr = 1; }
                if ((p = strstr(ctx, "\"d_w\":"))) { old_d_w = strtoull(p + 6, NULL, 10); has_dw = 1; }
                if ((p = strstr(ctx, "\"n_d\":"))) { old_n_d = strtoull(p + 6, NULL, 10); has_nd = 1; }
                if ((p = strstr(ctx, "\"n_u\":"))) { old_n_u = strtoull(p + 6, NULL, 10); has_nu = 1; }
                if ((p = strstr(ctx, "\"cpu\":["))) {
                    sscanf(p + 7, "%llu,%llu,%llu,%llu,%llu,%llu,%llu", &old_cpu[0], &old_cpu[1], &old_cpu[2], &old_cpu[3], &old_cpu[4], &old_cpu[5], &old_cpu[6]);
                }
            }
            fclose(fh);
        }
    }
    double time_d = has_time ? (now_time - old_time) : (now_time - (now_time - 2.0));
    if (time_d <= 0) time_d = 2.0;
    unsigned long long user = cpu_parts[0], nice = cpu_parts[1], system = cpu_parts[2], idle = cpu_parts[3], iowait = cpu_parts[4], irq = cpu_parts[5], softirq = cpu_parts[6];
    unsigned long long old_idle = old_cpu[3] + old_cpu[4];
    unsigned long long new_idle = idle + iowait;
    unsigned long long old_non_idle = old_cpu[0] + old_cpu[1] + old_cpu[2] + old_cpu[5] + old_cpu[6];
    unsigned long long new_non_idle = user + nice + system + irq + softirq;
    unsigned long long tot_old = old_idle + old_non_idle;
    unsigned long long tot_new = new_idle + new_non_idle;
    unsigned long long tot_delta = tot_new - tot_old;
    unsigned long long idle_delta = new_idle - old_idle;
    double cpu_pcent = (tot_delta > 0) ? (((double)(tot_delta - idle_delta) / tot_delta) * 100.0) : 0.0;
    double r_rt = has_dr ? ((double)(cur_d_r - old_d_r) / time_d) : 0.0;
    double w_rt = has_dw ? ((double)(cur_d_w - old_d_w) / time_d) : 0.0;
    double d_rt = has_nd ? ((double)(cur_net_down - old_n_d) / time_d) : 0.0;
    double u_rt = has_nu ? ((double)(cur_net_up - old_n_u) / time_d) : 0.0;
    if (r_rt < 0) r_rt = 0; if (w_rt < 0) w_rt = 0;
    if (d_rt < 0) d_rt = 0; if (u_rt < 0) u_rt = 0;
    fh = fopen(CACHE_FILE, "w");
    if (fh) {
        fprintf(fh, "{\"time\":%.6f,\"cpu\":[%llu,%llu,%llu,%llu,%llu,%llu,%llu],\"d_r\":%llu,\"d_w\":%llu,\"n_d\":%llu,\"n_u\":%llu}", now_time, cpu_parts[0], cpu_parts[1], cpu_parts[2], cpu_parts[3], cpu_parts[4], cpu_parts[5], cpu_parts[6], cur_d_r, cur_d_w, cur_net_down, cur_net_up);
        fclose(fh);
    }
    char temp_str[64];
    if (temp >= 100.0) strcpy(temp_str, "9999");
    else sprintf(temp_str, "%.1f", temp);
    char tmp_cpu[64], cpu_fmt[64];
    sprintf(tmp_cpu, "%.1f", cpu_pcent); pad(tmp_cpu, 5, cpu_fmt);
    char tmp_gpu[64], gpu_fmt[64];
    sprintf(tmp_gpu, "%.1f", gpu); pad(tmp_gpu, 5, gpu_fmt);
    char tmp_ram[64], ram_used_str[64];
    sprintf(tmp_ram, "%.2f", ram_used); pad(tmp_ram, 5, ram_used_str);
    char ram_tot_str[64], d_free_str[64], d_tot_str[64];
    sprintf(ram_tot_str, "%.2f", ram_tot); sprintf(d_free_str, "%.2f", d_free_GB); sprintf(d_tot_str, "%.2f", d_tot_GB);
    char f_r[64], f_w[64], f_d[64], f_u[64];
    fmt(r_rt, f_r); fmt(w_rt, f_w); fmt(d_rt, f_d); fmt(u_rt, f_u);
    char out_t[64];
    if (strcmp(temp_str, "9999") == 0) sprintf(out_t, "9999°C");
    else sprintf(out_t, "%s°C", temp_str);
    char out_r[64], out_w[64], out_d[64], out_u[64];
    if (strstr(f_r, "999999")) strcpy(out_r, "999999GB/s"); else strcpy(out_r, f_r);
    if (strstr(f_w, "999999")) strcpy(out_w, "999999GB/s"); else strcpy(out_w, f_w);
    if (strstr(f_d, "999999")) strcpy(out_d, "999999GB/s"); else strcpy(out_d, f_d);
    if (strstr(f_u, "999999")) strcpy(out_u, "999999GB/s"); else strcpy(out_u, f_u);
    printf(" T %s | C %s%% | G %s%% | M %s/%sGB | D %s/%sGB | R %s | W %s | ▼ %s | ▲ %s |", out_t, cpu_fmt, gpu_fmt, ram_used_str, ram_tot_str, d_free_str, d_tot_str, out_r, out_w, out_d, out_u);
    fprintf(stderr,
        "`                                       \n"
        "  SPRM (Simple Panel Resource Monitor)  \n"
        "             * C version *              \n"
        "                                        \n"
        "        T = Temperature                 \n"
        "        C = Total CPU Usage             \n"
        "        G = Total GPU Usage             \n"
        "        M = Total Memory Usage          \n"
        "        D = Total Disk Usage            \n"
        "        R = Total Disk Read             \n"
        "        W = Total Disk Write            \n"
        "        ▼ = Average Download Rate       \n"
        "        ▲ = Average Upload Rate         \n"
        "                                        \n"
        "           click to open btop           \n"
        "                                       .\n"
    );
    return 0;
}

// gcc -O2 SPRM.c -o SPRM-c && ./SPRM-c
