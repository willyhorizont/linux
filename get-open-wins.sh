#!/bin/bash

if ! command -v wmctrl >/dev/null 2>&1; then
    echo "[get-open-wins.sh] Error: missing dependencies 'wmctrl'..."
    exit 1
fi

WINDOW_IGNORE_FILE="$HOME/willyhorizont.github.io/.config/.windowignore"

get_open_wins_data() {
    if [ ! -f "$WINDOW_IGNORE_FILE" ]; then
        "$HOME/willyhorizont.github.io/linux/wmctrl-lxcapg.sh" | awk '{print $0}'
        return
    fi
    "$HOME/willyhorizont.github.io/linux/wmctrl-lxcapg.sh" | awk -v ignore_file="$WINDOW_IGNORE_FILE" '
        BEGIN {
            while ((getline < ignore_file) > 0) {
                gsub(/^[ \t]+|[ \t]+$/, "");
                if ($0 == "" || $0 ~ /^#/) continue;
                win_class = $1;
                sub(/^[^ \t]+[ \t]*/, "");
                title = $0;
                if (title != "") {
                    ignore_class_and_title[win_class] = title;
                } else {
                    ignore_class[win_class] = 1;
                }
            }
            close(ignore_file);
        }
        {
            cur_class = $7;
            cur_title = "";
            for(i=9; i<=NF; i++) {
                cur_title = (cur_title == "" ? $i : cur_title " " $i);
            }
            if (ignore_class[cur_class]) next;
            if (cur_class in ignore_class_and_title) {
                req_title = ignore_class_and_title[cur_class];
                if (cur_title ~ req_title) next;
            }
            print $0
        }
    '
}

OPEN_WINS_DATA=$(get_open_wins_data)

echo "$OPEN_WINS_DATA"
