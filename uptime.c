#define _POSIX_C_SOURCE 199309L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    char *pref = "";
    char *suff = " |";
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

    FILE *fh = fopen("/proc/uptime", "r");
    if (fh) {
        double secs;
        if (fscanf(fh, "%lf", &secs) == 1) {
            long long hours = (long long)(secs / 3600);
            int minutes = (int)(((long long)secs % 3600) / 60);

            if (hours > 9999999999999LL) {
                hours = 9999999999999LL;
            }

            char *k_lbl = " uptime ";
            char v_hrs[32], u_hrs[32], v_min[32], u_min[32];

            if (hours < 1000) {
                sprintf(v_hrs, "%3lld", hours);
                strcpy(u_hrs, "hours ");
                sprintf(v_min, "%2d", minutes);
                strcpy(u_min, "minutes");

                if (use_pango) {
                    printf("<span background='#000000' foreground='#00ADD8'>%s</span>"
                           "<span background='#000000' foreground='#FF1493'>%s</span>"
                           "<span background='#000000' foreground='#CCFF00'>%s</span>"
                           "<span background='#000000' foreground='#FF1493'>%s</span>"
                           "<span background='#000000' foreground='#CCFF00'>%s</span>"
                           "<span background='#000000' foreground='#FF1493'>%s</span>"
                           "<span background='#000000' foreground='#00ADD8'>%s</span>\n",
                           pref, k_lbl, v_hrs, u_hrs, v_min, u_min, suff);
                } else {
                    printf("%s%s%s%s%s%s%s\n", pref, k_lbl, v_hrs, u_hrs, v_min, u_min, suff);
                }
            } else {
                sprintf(v_hrs, "%13lld", hours);
                strcpy(u_hrs, "hours");

                if (use_pango) {
                    printf("<span background='#000000' foreground='#00ADD8'>%s</span>"
                           "<span background='#000000' foreground='#FF1493'>%s</span>"
                           "<span background='#000000' foreground='#CCFF00'>%s</span>"
                           "<span background='#000000' foreground='#FF1493'>%s</span>"
                           "<span background='#000000' foreground='#00ADD8'>%s</span>\n",
                           pref, k_lbl, v_hrs, u_hrs, suff);
                } else {
                    printf("%s%s%s%s%s\n", pref, k_lbl, v_hrs, u_hrs, suff);
                }
            }
        }
        fclose(fh);
    }
    return 0;
}

// gcc -O2 uptime.c -o uptime-c && ./uptime-c
