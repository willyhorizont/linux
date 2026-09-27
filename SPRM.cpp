#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>
#include <iomanip>
#include <chrono>
#include <regex>
#include <unistd.h>
#include <sys/statvfs.h>

#define CACHE_FILE "/tmp/sprm-cpp-cache.json"

std::string pad(const std::string& str, int len) {
    std::ostringstream ss;
    ss << std::setw(len) << str;
    return ss.str();
}

std::string fmt(double bytesps) {
    if (bytesps <= 0) return "      0B/s";
    std::vector<std::string> units = {"B/s", "KB/s", "MB/s"};
    int i = 0;
    double v = bytesps;
    while (v >= 1024 && i < 2) {
        v /= 1024;
        i++;
    }
    std::ostringstream ss;
    if (i == 0) ss << std::fixed << std::setprecision(3) << v;
    else ss << std::fixed << std::setprecision(2) << v;
    
    std::string num_str = ss.str();
    size_t dot = num_str.find('.');
    std::string f_p = (dot != std::string::npos) ? num_str.substr(0, dot) : num_str;
    std::string b_p = (dot != std::string::npos) ? num_str.substr(dot + 1) : "00";
    
    if (f_p.length() > 3) return "999999GB/s";
    
    return pad(f_p, 3) + "." + b_p + units[i];
}

int main() {
    std::string net_intrf = "lo";
    std::ifstream route_file("/proc/net/route");
    std::string line;
    if (route_file.is_open()) {
        std::getline(route_file, line);
        std::string iface, dest;
        while (route_file >> iface >> dest) {
            if (dest == "00000000" && iface != "lo") {
                net_intrf = iface;
                break;
            }
            std::getline(route_file, line);
        }
        route_file.close();
    }

    if (net_intrf == "lo") {
        std::ifstream dev_file("/proc/net/dev");
        if (dev_file.is_open()) {
            while (std::getline(dev_file, line)) {
                std::smatch m;
                if (std::regex_search(line, m, std::regex(R"(^\s*([a-zA-Z0-9_-]+):)"))) {
                    std::string candidate = m[1];
                    if (candidate != "lo" && !std::regex_search(candidate, std::regex(R"(^(sit|docker|veth|br-|virbr))"))) {
                        net_intrf = candidate;
                        break;
                    }
                }
            }
            dev_file.close();
        }
    }

    double temp = 0.0;
    for (int zone = 0; zone <= 5; ++zone) {
        std::ifstream temp_file("/sys/class/thermal/thermal_zone" + std::to_string(zone) + "/temp");
        long t_val;
        if (temp_file >> t_val) {
            temp_file.close();
            if (t_val > 0) {
                temp = static_cast<double>(t_val) / 1000.0;
                break;
            }
        }
    }

    std::vector<unsigned long long> cpu_parts(7, 0);
    std::ifstream stat_file("/proc/stat");
    if (stat_file.is_open()) {
        while (std::getline(stat_file, line)) {
            if (line.rfind("cpu ", 0) == 0) {
                std::istringstream iss(line.substr(4));
                for (int i = 0; i < 7; ++i) iss >> cpu_parts[i];
                break;
            }
        }
        stat_file.close();
    }

    double gpu = 0.0;
    // AMD
    if (access("/sys/class/drm/card0/device/gpu_busy_percent", F_OK) == 0) {
        std::ifstream gpu_file("/sys/class/drm/card0/device/gpu_busy_percent");
        if (gpu_file >> gpu) {}
        gpu_file.close();
    // Intel
    } else if (access("/sys/class/drm/card0/gt_act_freq_mhz", F_OK) == 0 && access("/sys/class/drm/card0/gt_max_freq_mhz", F_OK) == 0) {
        double act = 0, max = 1;
        std::ifstream f_act("/sys/class/drm/card0/gt_act_freq_mhz");
        std::ifstream f_max("/sys/class/drm/card0/gt_max_freq_mhz");
        if (f_act >> act && f_max >> max && max > 0) {
            gpu = (act / max) * 100.0;
        }
        f_act.close(); f_max.close();
    }

    std::ifstream mem_file("/proc/meminfo");
    unsigned long long mem_t = 0, mem_a = 0;
    if (mem_file.is_open()) {
        std::string label;
        unsigned long long val;
        while (mem_file >> label >> val) {
            if (label == "MemTotal:") mem_t = val;
            else if (label == "MemAvailable:") mem_a = val;
            std::getline(mem_file, line);
        }
        mem_file.close();
    }
    double ram_used = static_cast<double>(mem_t - mem_a) / 1024.0 / 1024.0;
    double ram_tot = static_cast<double>(mem_t) / 1024.0 / 1024.0;

    double d_tot_GB = 0.0, d_free_GB = 0.0;
    struct statvfs vfs;
    if (statvfs("/", &vfs) == 0) {
        d_tot_GB = static_cast<double>(vfs.f_blocks * vfs.f_frsize) / 1e9;
        d_free_GB = static_cast<double>(vfs.f_bavail * vfs.f_frsize) / 1e9;
    }

    std::ifstream disk_file("/proc/diskstats");
    unsigned long long cur_d_r = 0, cur_d_w = 0;
    if (disk_file.is_open()) {
        std::string dummy, dev;
        unsigned long long r, w;
        while (disk_file >> dummy >> dummy >> dev) {
            for(int i=0; i<3; ++i) disk_file >> dummy;
            disk_file >> r;
            for(int i=0; i<3; ++i) disk_file >> dummy;
            disk_file >> w;
            std::getline(disk_file, line);
            if (dev.rfind("sd", 0) == 0 || dev.rfind("nvme", 0) == 0 ||
                dev.rfind("mmcblk", 0) == 0 || dev.rfind("vd", 0) == 0) {
                cur_d_r += r;
                cur_d_w += w;
            }
        }
        disk_file.close();
    }
    cur_d_r *= 512;
    cur_d_w *= 512;

    std::ifstream net_file("/proc/net/dev");
    unsigned long long cur_net_down = 0, cur_net_up = 0;
    if (net_file.is_open()) {
        while (std::getline(net_file, line)) {
            if (line.find(net_intrf) != std::string::npos) {
                size_t colon = line.find(':');
                std::istringstream iss(line.substr(colon + 1));
                iss >> cur_net_down;
                for(int i=0; i<7; ++i) iss >> line;
                iss >> cur_net_up;
                break;
            }
        }
        net_file.close();
    }

    double now_time = std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::system_clock::now().time_since_epoch()).count() / 1e6;

    double old_time = 0.0;
    unsigned long long old_d_r = 0, old_d_w = 0, old_n_d = 0, old_n_u = 0;
    std::vector<unsigned long long> old_cpu(7, 0);
    bool has_time = false, has_dr = false, has_dw = false, has_nd = false, has_nu = false;

    std::ifstream cache_in(CACHE_FILE);
    if (cache_in.is_open()) {
        std::string ctx;
        std::getline(cache_in, ctx);
        std::smatch m;
        if (std::regex_search(ctx, m, std::regex(R"("-time":([0-9.]+))"))) { old_time = std::stod(m[1]); has_time = true; }
        if (std::regex_search(ctx, m, std::regex(R"("-d_r":([0-9]+))")))  { old_d_r = std::stoull(m[1]); has_dr = true; }
        if (std::regex_search(ctx, m, std::regex(R"("-d_w":([0-9]+))")))  { old_d_w = std::stoull(m[1]); has_dw = true; }
        if (std::regex_search(ctx, m, std::regex(R"("-n_d":([0-9]+))")))  { old_n_d = std::stoull(m[1]); has_nd = true; }
        if (std::regex_search(ctx, m, std::regex(R"("-n_u":([0-9]+))")))  { old_n_u = std::stoull(m[1]); has_nu = true; }
        if (std::regex_search(ctx, m, std::regex(R"("-cpu":\[([0-9,]+)\])"))) {
            std::istringstream css(m[1].str());
            std::string val;
            for(int i=0; i<7 && std::getline(css, val, ','); ++i) old_cpu[i] = std::stoull(val);
        }
        cache_in.close();
    }

    double time_d = has_time ? (now_time - old_time) : (now_time - (now_time - 2.0));
    if (time_d <= 0.0) time_d = 2.0;

    unsigned long long user = cpu_parts[0], nice = cpu_parts[1], system_v = cpu_parts[2], idle = cpu_parts[3], iowait = cpu_parts[4], irq = cpu_parts[5], softirq = cpu_parts[6];

    unsigned long long old_idle = old_cpu[3] + old_cpu[4];
    unsigned long long new_idle = idle + iowait;
    unsigned long long old_non_idle = old_cpu[0] + old_cpu[1] + old_cpu[2] + old_cpu[5] + old_cpu[6];
    unsigned long long new_non_idle = user + nice + system_v + irq + softirq;

    unsigned long long tot_old = old_idle + old_non_idle;
    unsigned long long tot_new = new_idle + new_non_idle;
    unsigned long long tot_delta = tot_new - tot_old;
    unsigned long long idle_delta = new_idle - old_idle;

    double cpu_pcent = (tot_delta > 0) ? ((static_cast<double>(tot_delta - idle_delta) / tot_delta) * 100.0) : 0.0;
    std::ostringstream cpu_ss; cpu_ss << std::fixed << std::setprecision(1) << cpu_pcent;
    std::string cpu_fmt = pad(cpu_ss.str(), 5);

    double r_rt = has_dr ? (static_cast<double>(cur_d_r - old_d_r) / time_d) : 0.0;
    double w_rt = has_dw ? (static_cast<double>(cur_d_w - old_d_w) / time_d) : 0.0;
    double d_rt = has_nd ? (static_cast<double>(cur_net_down - old_n_d) / time_d) : 0.0;
    double u_rt = has_nu ? (static_cast<double>(cur_net_up - old_n_u) / time_d) : 0.0;

    if (r_rt < 0) r_rt = 0; if (w_rt < 0) w_rt = 0;
    if (d_rt < 0) d_rt = 0; if (u_rt < 0) u_rt = 0;

    std::ofstream cache_out(CACHE_FILE);
    if (cache_out.is_open()) {
        cache_out << std::fixed << std::setprecision(6) << "{\"time\":" << now_time << ",\"cpu\":[" << cpu_parts[0] << "," << cpu_parts[1] << "," << cpu_parts[2] << "," << cpu_parts[3] << "," << cpu_parts[4] << "," << cpu_parts[5] << "," << cpu_parts[6] << "],\"d_r\":" << cur_d_r << ",\"d_w\":" << cur_d_w << ",\"n_d\":" << cur_net_down << ",\"n_u\":" << cur_net_up << "}";
        cache_out.close();
    }

    std::string temp_str = (temp >= 100.0) ? "9999" : [] (double t){
        std::ostringstream ss; ss << std::fixed << std::setprecision(1) << t; return ss.str();
    }(temp);
    std::string out_t = (temp_str == "9999") ? "9999°C" : temp_str + "°C";
    std::ostringstream g_ss, m_ss;
    g_ss << std::fixed << std::setprecision(1) << gpu;
    m_ss << std::fixed << std::setprecision(2) << ram_used;
    std::string gpu_fmt = pad(g_ss.str(), 5);
    std::string ram_used_str = pad(m_ss.str(), 5);
    std::ostringstream rt_ss, df_ss, dt_ss;
    rt_ss << std::fixed << std::setprecision(2) << ram_tot;
    df_ss << std::fixed << std::setprecision(2) << d_free_GB;
    dt_ss << std::fixed << std::setprecision(2) << d_tot_GB;
    std::string f_r = fmt(r_rt); std::string f_w = fmt(w_rt);
    std::string f_d = fmt(d_rt); std::string f_u = fmt(u_rt);
    std::string out_r = (f_r.find("999999") != std::string::npos) ? "999999GB/s" : f_r;
    std::string out_w = (f_w.find("999999") != std::string::npos) ? "999999GB/s" : f_w;
    std::string out_d = (f_d.find("999999") != std::string::npos) ? "999999GB/s" : f_d;
    std::string out_u = (f_u.find("999999") != std::string::npos) ? "999999GB/s" : f_u;
    std::cout << " T " << out_t << " | C " << cpu_fmt << "% | G " << gpu_fmt << "% | M " << ram_used_str << "/" << rt_ss.str() << "GB | D " << df_ss.str() << "/" << dt_ss.str() << "GB | R " << out_r << " | W " << out_w << " | ▼ " << out_d << " | ▲ " << out_u << " |";
    return 0;
}

// g++ -O3 SPRM.cpp -o SPRM-cpp && ./SPRM-cpp
