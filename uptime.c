// #define _POSIX_C_SOURCE 199309L
#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CMD_CLICK ""

int main(int argc, char *argv[]) {
    char mode[64] = "tint2";
    char pref[256] = "[";
    char suff[256] = "]";
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

            const char *k_lbl = "uptime ";
            char v_hrs[32], u_hrs[32], v_min[32], u_min[32];
            char out_txt[2048] = {0};
            size_t pos = 0;

            if (hours < 1000) {
                snprintf(v_hrs, sizeof(v_hrs), "%3lld", hours);
                snprintf(u_hrs, sizeof(u_hrs), "hours ");
                snprintf(v_min, sizeof(v_min), "%2d", minutes);
                snprintf(u_min, sizeof(u_min), "minutes");

                if (use_pango) {
                    pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#00ADD8'>%s</span>", pref);
                    pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#FF1493'>%s</span>", k_lbl);
                    pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#CCFF00'>%s</span>", v_hrs);
                    pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#FF1493'>%s</span>", u_hrs);
                    pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#CCFF00'>%s</span>", v_min);
                    pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#FF1493'>%s</span>", u_min);
                    pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#00ADD8'>%s</span>", suff);
                } else {
                    snprintf(out_txt, sizeof(out_txt), "%s%s%s%s%s%s%s", pref, k_lbl, v_hrs, u_hrs, v_min, u_min, suff);
                }
            } else {
                snprintf(v_hrs, sizeof(v_hrs), "%13lld", hours);
                snprintf(u_hrs, sizeof(u_hrs), "hours");

                if (use_pango) {
                    pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#00ADD8'>%s</span>", pref);
                    pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#FF1493'>%s</span>", k_lbl);
                    pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#CCFF00'>%s</span>", v_hrs);
                    pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#FF1493'>%s</span>", u_hrs);
                    pos += snprintf(out_txt + pos, sizeof(out_txt) - pos, "<span background='#000000' foreground='#00ADD8'>%s</span>", suff);
                } else {
                    snprintf(out_txt, sizeof(out_txt), "%s%s%s%s%s", pref, k_lbl, v_hrs, u_hrs, suff);
                }
            }

            const char *tooltip_txt = "";

            if (strcmp(mode, "xfce4-panel") == 0) {
                printf("<txt>%s</txt>\n", out_txt);
                printf("<txtclick>%s</txtclick>\n", CMD_CLICK);
                printf("<tool>%s</tool>\n", tooltip_txt);
            } else {
                printf("%s\n", out_txt);
                fprintf(stderr, "\x1b[2J%s", tooltip_txt);
            }
        }
        fclose(fh);
    }
    return 0;
}

// gcc -O2 uptime.c -o uptime-c && ./uptime-c
