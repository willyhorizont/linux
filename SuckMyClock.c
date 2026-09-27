#include <stdio.h>
#include <time.h>

int get_total_days(int year, int month) {
    int days[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    if (month == 2) {
        if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
            return 29;
        }
    }
    return days[month - 1];
}

int main() {
    time_t t = time(NULL);
    struct tm *tm_info = localtime(&t);

    char month_num[4], day_num[4];
    char date_string[64], time_24[32], time_12[32];

    strftime(month_num, sizeof(month_num), "%m", tm_info);
    strftime(day_num, sizeof(day_num), "%d", tm_info);
    
    int year = tm_info->tm_year + 1900;
    int month_int = tm_info->tm_mon + 1;
    int total_days = get_total_days(year, month_int);

    strftime(date_string, sizeof(date_string), "%a, %d %b %Y", tm_info);
    strftime(time_24, sizeof(time_24), "%H:%M:%S", tm_info);
    strftime(time_12, sizeof(time_12), "%I:%M:%S %p", tm_info);

    printf("| %s/12 months | %s/%d days | %s | %s | %s ", month_num, day_num, total_days, date_string, time_24, time_12);

    return 0;
}

// gcc -O2 SuckMyClock.c -o SuckMyClock-c && ./SuckMyClock-c
