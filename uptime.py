#!/usr/bin/env python3
import sys
import os

def main():
    pref = ""
    suff = " |"
    use_pango = False

    args = sys.argv[1:]
    i = 0
    while i < len(args):
        if args[i] == "--pref" and i + 1 < len(args):
            pref = args[i+1]
            i += 2
        elif args[i] == "--suff" and i + 1 < len(args):
            suff = args[i+1]
            i += 2
        elif args[i] == "--pango":
            use_pango = True
            i += 1
        else:
            i += 1

    if os.path.exists("/proc/uptime"):
        try:
            with open("/proc/uptime", "r") as f:
                line = f.read()
            secs = float(line.split()[0])
            hours = int(secs // 3600)
            minutes = int((secs % 3600) // 60)

            if hours > 9999999999999:
                hours = 9999999999999

            k_lbl = " uptime "

            if hours < 1000:
                v_hrs = f"{hours:3d}"
                v_min = f"{minutes:02d}"
                if use_pango:
                    out = (f"<span background='#000000' foreground='#00ADD8'>{pref}</span>"
                           f"<span background='#000000' foreground='#FF1493'>{k_lbl}</span>"
                           f"<span background='#000000' foreground='#CCFF00'>{v_hrs}</span>"
                           f"<span background='#000000' foreground='#FF1493'>hours </span>"
                           f"<span background='#000000' foreground='#CCFF00'>{v_min}</span>"
                           f"<span background='#000000' foreground='#FF1493'>minutes</span>"
                           f"<span background='#000000' foreground='#00ADD8'>{suff}</span>")
                else:
                    out = f"{pref}{k_lbl}{v_hrs}hours {v_min}minutes{suff}"
            else:
                v_hrs = f"{hours:13d}"
                if use_pango:
                    out = (f"<span background='#000000' foreground='#00ADD8'>{pref}</span>"
                           f"<span background='#000000' foreground='#FF1493'>{k_lbl}</span>"
                           f"<span background='#000000' foreground='#CCFF00'>{v_hrs}</span>"
                           f"<span background='#000000' foreground='#FF1493'>hours</span>"
                           f"<span background='#000000' foreground='#00ADD8'>{suff}</span>")
                else:
                    out = f"{pref}{k_lbl}{v_hrs}hours{suff}"
            
            print(out, flush=True)
        except Exception:
            pass

if __name__ == "__main__":
    main()
