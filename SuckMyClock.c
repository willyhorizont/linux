#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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

int main(int argc, char *argv[]) {
    char *pref = "| ";
    char *suff = " ";
    int use_pango = 0;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--pref") == 0 && i + 1 < argc) {
            pref = argv[++i];
        } else if (strcmp(argv[i], "--suff") == 0 && i + 1 < argc) {
            suff = argv[++i];
        } else if (strcmp(argv[i], "--pango") == 0) {
            use_pango = 1;
        }
    }

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
    strftime(time_12, sizeof(time_12), "%I:%M:%S", tm_info);

    char total_days_str[12];
    sprintf(total_days_str, "%d", total_days);

    char am_pm_str[8];
    strftime(am_pm_str, sizeof(am_pm_str), "%p", tm_info);

    if (use_pango) {
        printf("<span background='#000000' foreground='#00ADD8'>%s</span>", pref);

        printf("<span background='#000000' foreground='#CCFF00'>%s/12 </span>", month_num);
        printf("<span background='#000000' foreground='#FF1493'>months</span>");
        printf("<span background='#000000' foreground='#00ADD8'> | </span>");

        printf("<span background='#000000' foreground='#CCFF00'>%s</span>", day_num);
        printf("<span background='#000000' foreground='#CCFF00'>/</span>");
        printf("<span background='#000000' foreground='#CCFF00'>%s </span>", total_days_str);
        printf("<span background='#000000' foreground='#FF1493'>days</span>");
        printf("<span background='#000000' foreground='#00ADD8'> | </span>");

        printf("<span background='#000000' foreground='#CCFF00'>%s</span>", date_string);
        printf("<span background='#000000' foreground='#00ADD8'> | </span>");

        printf("<span background='#000000' foreground='#CCFF00'>%s</span>", time_24);
        printf("<span background='#000000' foreground='#00ADD8'> | </span>");

        printf("<span background='#000000' foreground='#CCFF00'>%s </span>", time_12);
        printf("<span background='#000000' foreground='#FF1493'>%s</span>", am_pm_str);

        printf("<span background='#000000' foreground='#00ADD8'>%s</span>", suff);
    } else {
        printf("%s%s/12 months | %s/%d days | %s | %s | %s %s%s", pref, month_num, day_num, total_days, date_string, time_24, time_12, am_pm_str, suff);
    }
    printf("\n");

    fprintf(stderr,
        " SuckMyClock C version;\n"
        " click to open calcurse\n"
    );

    return 0;
}

// gcc -O2 SuckMyClock.c -o SuckMyClock-c && ./SuckMyClock-c
