#include <iostream>
#include <chrono>
#include <ctime>
#include <iomanip>
#include <string>
#include <cstring>

int get_total_days(int year, int month) {
    const int days[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    if (month == 2) {
        if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
            return 29;
        }
    }
    return days[month - 1];
}

std::string format_time(const std::tm* tm_info, const std::string& fmt) {
    char buf[64];
    std::strftime(buf, sizeof(buf), fmt.c_str(), tm_info);
    return std::string(buf);
}

int main(int argc, char *argv[]) {
    std::string pref = " ";
    std::string suff = " ";
    std::string sep = " | ";
    bool use_pango = false;

    for (int i = 1; i < argc; i++) {
        if (std::strcmp(argv[i], "--pref") == 0 && i + 1 < argc) {
            pref = argv[++i];
        } else if (std::strcmp(argv[i], "--suff") == 0 && i + 1 < argc) {
            suff = argv[++i];
        } else if (std::strcmp(argv[i], "--sep") == 0 && i + 1 < argc) {
            sep = argv[++i];
        } else if (std::strcmp(argv[i], "--pango") == 0) {
            use_pango = true;
        }
    }

    auto now = std::chrono::system_clock::now();
    std::time_t t = std::chrono::system_clock::to_time_t(now);
    std::tm* tm_info = std::localtime(&t);

    std::string month_num = format_time(tm_info, "%m");
    std::string day_num = format_time(tm_info, "%d");
    
    int year = tm_info->tm_year + 1900;
    int month_int = tm_info->tm_mon + 1;
    int total_days = get_total_days(year, month_int);

    std::string date_string = format_time(tm_info, "%a, %d %b %Y");
    std::string time_24 = format_time(tm_info, "%H:%M:%S");
    std::string time_12 = format_time(tm_info, "%I:%M:%S");
    std::string am_pm_str = format_time(tm_info, "%p");

    if (use_pango) {
        if (!pref.empty()) std::cout << "<span background='#000000' foreground='#00ADD8'>" << pref << "</span>";

        std::cout << "<span background='#000000' foreground='#CCFF00'>" << month_num << "/12 </span>";
        std::cout << "<span background='#000000' foreground='#FF1493'>months</span>";
        std::cout << "<span background='#000000' foreground='#00ADD8'>" << sep << "</span>";

        std::cout << "<span background='#000000' foreground='#CCFF00'>" << day_num << "</span>";
        std::cout << "<span background='#000000' foreground='#CCFF00'>/</span>";
        std::cout << "<span background='#000000' foreground='#CCFF00'>" << total_days << " </span>";
        std::cout << "<span background='#000000' foreground='#FF1493'>days</span>";
        std::cout << "<span background='#000000' foreground='#00ADD8'>" << sep << "</span>";

        std::cout << "<span background='#000000' foreground='#CCFF00'>" << date_string << "</span>";
        std::cout << "<span background='#000000' foreground='#00ADD8'>" << sep << "</span>";

        std::cout << "<span background='#000000' foreground='#CCFF00'>" << time_24 << "</span>";
        std::cout << "<span background='#000000' foreground='#00ADD8'>" << sep << "</span>";

        std::cout << "<span background='#000000' foreground='#CCFF00'>" << time_12 << " </span>";
        std::cout << "<span background='#000000' foreground='#FF1493'>" << am_pm_str << "</span>";

        if (!suff.empty()) std::cout << "<span background='#000000' foreground='#00ADD8'>" << suff << "</span>";
    } else {
        std::cout << pref << month_num << "/12 months" << sep << day_num << "/" << total_days << " days" << sep << date_string << sep << time_24 << sep << time_12 << " " << am_pm_str << suff;
    }
    std::cout << std::endl;

    std::cerr << R"( SuckMyClock (My Suckless Clock) C++ version;
 click to open calcurse)";

    return 0;
}

// g++ -O3 SuckMyClock.cpp -o SuckMyClock-cpp && ./SuckMyClock-cpp
