#include <iostream>
#include <fstream>
#include <string>
#include <iomanip>

int main(int argc, char *argv[]) {
    std::string pref = "";
    std::string suff = " |";
    bool use_pango = false;

    for (int i = 1; i < argc; i++) {
        std::string arg = argv[i];
        if (arg == "--pref" && i + 1 < argc) {
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

    std::string k_lbl = " uptime ";

    if (hours < 1000) {
        if (use_pango) {
            std::cout << "<span background='#000000' foreground='#00ADD8'>" << pref << "</span>"
                      << "<span background='#000000' foreground='#FF1493'>" << k_lbl << "</span>"
                      << "<span background='#000000' foreground='#CCFF00'>" << std::setw(3) << hours << "</span>"
                      << "<span background='#000000' foreground='#FF1493'>hours </span>"
                      << "<span background='#000000' foreground='#CCFF00'>" << std::setw(2) << std::setfill('0') << minutes << "</span>"
                      << "<span background='#000000' foreground='#FF1493'>" << std::setfill(' ') << "minutes</span>"
                      << "<span background='#000000' foreground='#00ADD8'>" << suff << "</span>\n";
        } else {
            std::cout << pref << k_lbl << std::setw(3) << hours << "hours " 
                      << std::setw(2) << std::setfill('0') << minutes << "minutes" 
                      << std::setfill(' ') << suff << "\n";
        }
    } else {
        if (use_pango) {
            std::cout << "<span background='#000000' foreground='#00ADD8'>" << pref << "</span>"
                      << "<span background='#000000' foreground='#FF1493'>" << k_lbl << "</span>"
                      << "<span background='#000000' foreground='#CCFF00'>" << std::setw(13) << hours << "</span>"
                      << "<span background='#000000' foreground='#FF1493'>hours</span>"
                      << "<span background='#000000' foreground='#00ADD8'>" << suff << "</span>\n";
        } else {
            std::cout << pref << k_lbl << std::setw(13) << hours << "hours" << suff << "\n";
        }
    }

    return 0;
}

// g++ -O3 uptime.cpp -o uptime-cpp && ./uptime-cpp
