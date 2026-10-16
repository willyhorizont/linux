#!/bin/bash

get_is_tux_fit() {
    local wm_data=$(wmctrl -d | grep '*')
    local ws=$(echo "$wm_data" | awk '{print $1}')
    local work_area=$(echo "$wm_data" | grep -oE 'WA: [0-9]+,[0-9]+ [0-9]+x[0-9]+')
    local WA_W=$(echo "$work_area" | awk '{print $3}' | cut -d'x' -f1)
    local WA_H=$(echo "$work_area" | awk '{print $3}' | cut -d'x' -f2)

    local tux_w=20
    local tux_h=20

    local fit_status=$(wmctrl -l -x -G | awk -v current_ws="$ws" \
        -v scrn_w="$WA_W" -v scrn_h="$WA_H" \
        -v tw="$tux_w" -v th="$tux_h" '
    BEGIN {
        step_in_px = 10
        win_count = 0
    }
    $2 == current_ws {
        if ($7 == "pcmanfm.Pcmanfm" && $9 == "pcmanfm") next;
        if ($7 == "plank.Plank" && $9 == "plank") next;
        if ($7 == "tint2.Tint2") next;
        if ($7 == "xpenguins.Xpenguins") next;
        if ($7 ~ /welcome-window|idle-window/) next;
        x1[win_count] = $3
        y1[win_count] = $4
        x2[win_count] = $3 + $5
        y2[win_count] = $4 + $6
        win_count++
    }
    END {
        if (scrn_w <= 0 || scrn_h <= 0) {
            print "NO_FIT"
            exit 0
        }

        for (y = 0; y <= (scrn_h - th); y += step_in_px) {
            for (x = 0; x <= (scrn_w - tw); x += step_in_px) {
                blocked = 0
                tx1 = x; ty1 = y; tx2 = x + tw; ty2 = y + th;
                for (i = 0; i < win_count; i++) {
                    # box collision detection logic (Axis-Aligned Bounding Box)
                    if (!(tx2 <= x1[i] || tx1 >= x2[i] || ty2 <= y1[i] || ty1 >= y2[i])) {
                        blocked = 1
                        break
                    }
                }
                if (blocked == 0) {
                    print "FIT"
                    exit 0
                }
            }
        }
        print "NO_FIT"
    }')

    if [ "$fit_status" = "FIT" ]; then
        return 0
    else
        return 1
    fi
}

get_is_tux_fit
if [ $? -eq 0 ]; then
    IS_TUX_FIT=true
else
    IS_TUX_FIT=false
fi

if [ "$IS_TUX_FIT" = false ]; then
    echo "tux not fit"
else
    echo "tux can fit"
fi
