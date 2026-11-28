// #define _POSIX_C_SOURCE 199309L
#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define CMD_CLICK "xfce4-terminal -e calcurse"

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
    char mode[32] = "tint2";
    char pref[256] = "[";
    char suff[256] = "]";
    char sep[256] = " | ";
    int use_pango = 0;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--mode") == 0 && i + 1 < argc) {
            i++;
            if (strcmp(argv[i], "tint2") == 0 || strcmp(argv[i], "xfce4-panel") == 0) {
                snprintf(mode, sizeof(mode), "%s", argv[i]);
            }
        } else if (strcmp(argv[i], "--pref") == 0 && i + 1 < argc) {
            snprintf(pref, sizeof(pref), "%s", argv[++i]);
        } else if (strcmp(argv[i], "--suff") == 0 && i + 1 < argc) {
            snprintf(suff, sizeof(suff), "%s", argv[++i]);
        } else if (strcmp(argv[i], "--sep") == 0 && i + 1 < argc) {
            snprintf(sep, sizeof(sep), "%s", argv[++i]);
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
    snprintf(total_days_str, sizeof(total_days_str), "%d", total_days);

    char am_pm_str[8];
    strftime(am_pm_str, sizeof(am_pm_str), "%p", tm_info);

    char out_txt[2048] = {0};
    size_t pos = 0;

    if (use_pango) {
        pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#00ADD8'>%s</span>", pref);

        pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#CCFF00'>%s/12 </span>", month_num);
        pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#FF1493'>months</span>");
        pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#00ADD8'>%s</span>", sep);

        pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#CCFF00'>%s</span>", day_num);
        pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#CCFF00'>/</span>");
        pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#CCFF00'>%s </span>", total_days_str);
        pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#FF1493'>days</span>");
        pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#00ADD8'>%s</span>", sep);

        pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#CCFF00'>%s</span>", date_string);
        pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#00ADD8'>%s</span>", sep);

        pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#CCFF00'>%s</span>", time_24);
        pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#00ADD8'>%s</span>", sep);

        pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#CCFF00'>%s </span>", time_12);
        pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#FF1493'>%s</span>", am_pm_str);

        pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#00ADD8'>%s</span>", suff);
    } else {
        snprintf(out_txt, sizeof(out_txt), "%s%s/12 months%s%s/%d days%s%s%s%s%s%s %s%s", pref, month_num, sep, day_num, total_days, sep, date_string, sep, time_24, sep, time_12, am_pm_str, suff);
    }

    const char *tooltip_txt =
        "SuckMyClock (My Suckless Clock) C version\n"
        "click to open calcurse";

    if (strcmp(mode, "xfce4-panel") == 0) {
        printf("<txt>%s</txt>\n", out_txt);
        printf("<txtclick>%s</txtclick>\n", CMD_CLICK);
        printf("<tool>%s</tool>\n", tooltip_txt);
    } else {
        printf("%s\n", out_txt);
        fprintf(stderr, "\x1b[2J%s", tooltip_txt);
    }

    return 0;
}

// gcc -O2 SuckMyClock.c -o SuckMyClock-c && ./SuckMyClock-c
