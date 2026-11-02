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
    if (!fh) return 1;

    double secs;
    if (fscanf(fh, "%lf", &secs) != 1) {
        fclose(fh);
        return 1;
    }
    fclose(fh);

    long long hours = (long long)(secs / 3600);
    int minutes = (int)(((long)(secs) % 3600) / 60);

    if (hours > 9999999999999LL) {
        hours = 9999999999999LL;
    }

    char *k_lbl = " uptime ";

    if (hours < 1000) {
        if (use_pango) {
            printf("<span background='#000000' foreground='#00ADD8'>%s</span>"
                   "<span background='#000000' foreground='#FF1493'>%s</span>"
                   "<span background='#000000' foreground='#CCFF00'>%3lld</span>"
                   "<span background='#000000' foreground='#FF1493'>hours </span>"
                   "<span background='#000000' foreground='#CCFF00'>%02d</span>"
                   "<span background='#000000' foreground='#FF1493'>minutes</span>"
                   "<span background='#000000' foreground='#00ADD8'>%s</span>\n",
                   pref, k_lbl, hours, minutes, suff);
        } else {
            printf("%s%s%3lldhours %02dminutes%s\n", pref, k_lbl, hours, minutes, suff);
        }
    } else {
        if (use_pango) {
            printf("<span background='#000000' foreground='#00ADD8'>%s</span>"
                   "<span background='#000000' foreground='#FF1493'>%s</span>"
                   "<span background='#000000' foreground='#CCFF00'>%13lld</span>"
                   "<span background='#000000' foreground='#FF1493'>hours</span>"
                   "<span background='#000000' foreground='#00ADD8'>%s</span>\n",
                   pref, k_lbl, hours, suff);
        } else {
            printf("%s%s%13lldhours%s\n", pref, k_lbl, hours, suff);
        }
    }

    return 0;
}

// gcc -O2 uptime.c -o uptime-c && ./uptime-c
