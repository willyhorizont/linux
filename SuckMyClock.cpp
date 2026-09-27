#include <iostream>
#include <chrono>
#include <ctime>
#include <iomanip>
#include <string>

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

int main() {
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
    std::string time_12 = format_time(tm_info, "%I:%M:%S %p");

    std::cout << "| " << month_num << "/12 months | " << day_num << "/" << total_days << " days | " << date_string << " | " << time_24 << " | " << time_12 << " ";

    return 0;
}

// g++ -O3 SuckMyClock.cpp -o SuckMyClock-cpp && ./SuckMyClock-cpp
