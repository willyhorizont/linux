#!/bin/bash

if ! command -v xdotool >/dev/null 2>&1 || ! command -v wmctrl >/dev/null 2>&1; then
    echo "Error: missing dependencies 'xdotool wmctrl'..."
    exit 1
fi

WINDOW_LIST=""

WINDOW_LIST=$(wmctrl -l -x -G 2>/dev/null)

while read -r WID; do
    [ -z "$WID" ] && continue
    WID_HEX=$(printf "0x%08x" "$WID")
    if [ -n "$WINDOW_LIST" ] && echo "$WINDOW_LIST" | grep -q "^$WID_HEX"; then
        continue
    fi
    eval $(xdotool getwindowgeometry --shell "$WID" 2>/dev/null)
    WS=$(xdotool get_desktop_for_window "$WID" 2>/dev/null)
    if [ -z "$WS" ]; then
        WS=-1
    fi
    WM_CLASS=$(xprop -id "$WID" WM_CLASS 2>/dev/null | awk -F'"' '{print $2"."$4}')
    if [ "$WM_CLASS" = "." ] || [ -z "$WM_CLASS" ]; then
        WM_CLASS="N/A"
    fi
    WM_CLIENT_MACHINE=$(xprop -id "$WID" WM_CLIENT_MACHINE 2>/dev/null | awk -F'"' '{print $2}')
    if [ "$WM_CLIENT_MACHINE" = "." ] || [ -z "$WM_CLIENT_MACHINE" ]; then
        WM_CLIENT_MACHINE="N/A"
    fi
    WM_NAME=$(xdotool getwindowname "$WID" 2>/dev/null)
    NEW_ENTRY=$(echo "$WID_HEX $WS $X $Y $WIDTH $HEIGHT $WM_CLASS $WM_CLIENT_MACHINE $WM_NAME")
    if [ -z "$WINDOW_LIST" ]; then
        WINDOW_LIST="$NEW_ENTRY"
    else
        WINDOW_LIST="$WINDOW_LIST"$'\n'"$NEW_ENTRY"
    fi

done < <(xdotool search --onlyvisible --name ".*" 2>/dev/null)

echo "$WINDOW_LIST" | awk '
{
    lines[NR] = $0
    for (i = 1; i <= 8; i++) {
        if (length($i) > max[i]) {
            max[i] = length($i)
        }
    }
}
END {
    for (j = 1; j <= NR; j++) {
        $0 = lines[j]
        match($0, /([^ \t]+[ \t]+){8}/)
        title_start = RSTART + RLENGTH
        title = substr($0, title_start)
        if (NF < 9) {
            title = ""
        }
        fmt = sprintf("%%-%ds    %%-%ds    %%-%ds    %%-%ds    %%-%ds    %%-%ds    %%-%ds    %%-%ds    %%s\n", 
                      max[1], max[2], max[3], max[4], max[5], max[6], max[7], max[8])
        printf fmt, $1, $2, $3, $4, $5, $6, $7, $8, title
    }
}'
