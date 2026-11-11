#!/bin/bash

SCRIPT_NAME="rofi-windows-task-view-mac-mission-control.sh"
GET_OPEN_WINS_SCRIPT="$HOME/willyhorizont.github.io/linux/get-open-wins.sh"

if [ ! -f "$GET_OPEN_WINS_SCRIPT" ]; then
    notify-send "[$SCRIPT_NAME]" "Error: $GET_OPEN_WINS_SCRIPT not found!"
    exit 1
fi

WINS_RAW=$("$GET_OPEN_WINS_SCRIPT")

DESKTOP_NAMES=$(xprop -root _NET_DESKTOP_NAMES 2>/dev/null | awk -F'"' '{for(i=2; i<=NF; i+=2) print $i}')

ROFI_LIST=$(echo "$WINS_RAW" | awk -v names_str="$DESKTOP_NAMES" '
    BEGIN {
        split(names_str, names_arr, "\n");
    }
    {
        if ($2 == -1) next;
        ws_name = names_arr[$2 + 1];
        if (ws_name == "") ws_name = $2;
        gsub(/[^0-9]/, "", ws_name);
        window_title = "";
        for(i=9; i<=NF; i++) {
            window_title = (window_title == "" ? $i : window_title " " $i);
        }
        lns[NR] = $1 " " ws_name " " window_title
        wm_classes[NR] = $7
        if (length($7) > max_7) {
            max_7 = length($7)
        }
    }
    END {
        for (j = 1; j <= NR; j++) {
            if (!lns[j]) continue;
            split(lns[j], parts, " ");
            win_id = parts[1];
            ws = parts[2];
            match(lns[j], /([^ \t]+[ \t]+){2}/)
            title = substr(lns[j], RSTART + RLENGTH)
            fmt = sprintf("%%s   %%s   %%-%ds   %%s\n", max_7)
            printf fmt, win_id, ws, wm_classes[j], title
        }
    }
' | sort -V -k2)

if [ -z "$ROFI_LIST" ]; then
    exit 0
fi

ROFI_THEME="
    window { width: 90%; }
"

ROFI_INPUT=$(echo -e "$ROFI_LIST" | rofi -dmenu -i -p "rofi Windows Task View / Mac Mission Control" -theme-str "$ROFI_THEME")

if [ -z "$ROFI_INPUT" ]; then
    exit 0
fi

TRGT_WIN_ID=$(echo "$ROFI_INPUT" | awk '{print $1}')

if [ -n "$TRGT_WIN_ID" ]; then
    xdotool windowactivate "$TRGT_WIN_ID" 2>/dev/null
fi
