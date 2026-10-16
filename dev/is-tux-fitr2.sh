#!/bin/bash

get_is_tux_fit() {
    local wm_data=$(wmctrl -d | grep '*')
    local ws=$(echo "$wm_data" | awk '{print $1}')
    local wrk_area=$(echo "$wm_data" | grep -oE 'WA: [0-9]+,[0-9]+ [0-9]+x[0-9]+')
    local wa_w=$(echo "$wrk_area" | awk '{print $3}' | cut -d'x' -f1)
    local wa_h=$(echo "$wrk_area" | awk '{print $3}' | cut -d'x' -f2)

    local tux_w=20
    local tux_h=20

    local fit_stat=$(wmctrl -l -x -G | awk -v cur_ws="$ws" \
        -v scrn_w="$wa_w" -v scrn_h="$wa_h" \
        -v tw="$tux_w" -v th="$tux_h" '
    BEGIN {
        step_in_px = 10
    }
    $2 == cur_ws {
        if ($7 == "pcmanfm.Pcmanfm" && $9 == "pcmanfm") next;
        if ($7 == "plank.Plank" && $9 == "plank") next;
        if ($7 == "tint2.Tint2") next;
        if ($7 == "xpenguins.Xpenguins") next;
        if ($7 ~ /welcome-window|idle-window/) next;

        start_x = int($3 / step_in_px)
        start_y = int($4 / step_in_px)
        end_x = int(($3 + $5) / step_in_px)
        end_y = int(($4 + $6) / step_in_px)

        for (i = start_y; i <= end_y; i++) {
            for (j = start_x; j <= end_x; j++) {
                grid[i, j] = 1
            }
        }
    }
    END {
        if (scrn_w <= 0 || scrn_h <= 0) {
            print "NO_FIT"
            exit 0
        }

        max_grid_x = int(scrn_w / step_in_px)
        max_grid_y = int(scrn_h / step_in_px)
        req_tw = int(tw / step_in_px)
        req_th = int(th / step_in_px)

        for (y = 0; y <= (max_grid_y - req_th); y++) {
            for (x = 0; x <= (max_grid_x - req_tw); x++) {
                empty_cell = 1
                for (i = 0; i < req_th; i++) {
                    for (j = 0; j < req_tw; j++) {
                        if (grid[y + i, x + j] == 1) {
                            empty_cell = 0
                            break
                        }
                    }
                    if (empty_cell == 0) break
                }
                if (empty_cell == 1) {
                    print "FIT"
                    exit 0
                }
            }
        }
        print "NO_FIT"
    }')

    if [ "$fit_stat" = "FIT" ]; then
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
