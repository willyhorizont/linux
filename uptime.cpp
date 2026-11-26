#include <iostream>
#include <fstream>
#include <string>

#define CMD_CLICK ""

std::string pad_num(long long val, size_t width) {
    std::string s = std::to_string(val);
    if (s.length() < width) {
        return std::string(width - s.length(), ' ') + s;
    }
    return s;
}

int main(int argc, char *argv[]) {
    std::string mode = "tint2";
    std::string pref = "[";
    std::string suff = "]";
    bool use_pango = false;

    for (int i = 1; i < argc; i++) {
        std::string arg = argv[i];
        if (arg == "--mode" && i + 1 < argc) {
            i++;
            if (std::string(argv[i]) == "tint2" || std::string(argv[i]) == "xfce4-panel") {
                mode = argv[i];
            }
        } else if (arg == "--pref" && i + 1 < argc) {
            pref = argv[++i];
        } else if (arg == "--suff" && i + 1 < argc) {
            suff = argv[++i];
        } else if (arg == "--pango") {
            use_pango = true;
        }
    }

    std::ifstream fh("/proc/uptime");
    if (!fh.is_open()) return 1;

    double secs;
    if (!(fh >> secs)) return 1;
    fh.close();

    long long hours = static_cast<long long>(secs / 3600);
    int minutes = (static_cast<long>(secs) % 3600) / 60;

    if (hours > 9999999999999LL) {
        hours = 9999999999999LL;
    }

    std::string k_lbl = "uptime ";
    std::string final_out = "";

    if (hours < 1000) {
        std::string v_hrs = pad_num(hours, 3);
        std::string v_min = pad_num(minutes, 2);

        if (use_pango) {
            final_out += "<span background='#000000' foreground='#00ADD8'>" + pref + "</span>";
            final_out += "<span background='#000000' foreground='#FF1493'>" + k_lbl + "</span>";
            final_out += "<span background='#000000' foreground='#CCFF00'>" + v_hrs + "</span>";
            final_out += "<span background='#000000' foreground='#FF1493'>hours </span>";
            final_out += "<span background='#000000' foreground='#CCFF00'>" + v_min + "</span>";
            final_out += "<span background='#000000' foreground='#FF1493'>minutes</span>";
            final_out += "<span background='#000000' foreground='#00ADD8'>" + suff + "</span>";
        } else {
            final_out = pref + k_lbl + v_hrs + "hours " + v_min + "minutes" + suff;
        }
    } else {
        std::string v_hrs = pad_num(hours, 13);

        if (use_pango) {
            final_out += "<span background='#000000' foreground='#00ADD8'>" + pref + "</span>";
            final_out += "<span background='#000000' foreground='#FF1493'>" + k_lbl + "</span>";
            final_out += "<span background='#000000' foreground='#CCFF00'>" + v_hrs + "</span>";
            final_out += "<span background='#000000' foreground='#FF1493'>hours</span>";
            final_out += "<span background='#000000' foreground='#00ADD8'>" + suff + "</span>";
        } else {
            final_out = pref + k_lbl + v_hrs + "hours" + suff;
        }
    }

    std::string tooltip_txt = "";

    if (mode == "xfce4-panel") {
        std::cout << "<txt>" << final_out << "</txt>\n";
        std::cout << "<txtclick>" << CMD_CLICK << "</txtclick>\n";
        std::cout << "<tool>" << tooltip_txt << "</tool>\n";
    } else {
        std::cout << final_out << "\n";
        std::cerr << "\x1b[2J" << tooltip_txt;
    }

    return 0;
}

// g++ -O3 uptime.cpp -o uptime-cpp && ./uptime-cpp
