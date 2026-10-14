#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    notify-send "tile-cur-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

tile() {
    local cur_win_i=$1
    local x=$2; local y=$3
    local w=$4; local h=$5
    local o=$6

    if [ "$cur_win_i" -eq "$((OPEN_WINS_COUNT - 1))" ]; then
        local win_id="${win_array[$cur_win_i]}"
        wmctrl -i -r "$win_id" -b remove,maximized_vert,maximized_horz
        xdotool windowsize "$win_id" "$w" "$h"
        xdotool windowmove "$win_id" "$x" "$y"
        return 0
    fi

    if [ "$o" = "v" ]; then
        local sub_w=$((w / 2))
        local rght_x=$((x + sub_w))
        
        local win_id="${win_array[$cur_win_i]}"
        wmctrl -i -r "$win_id" -b remove,maximized_vert,maximized_horz
        xdotool windowsize "$win_id" "$sub_w" "$h"
        xdotool windowmove "$win_id" "$rght_x" "$y"
        
        tile "$((cur_win_i + 1))" "$x" "$y" "$sub_w" "$h" "h"
    else
        local sub_h=$((h / 2))
        
        local win_id="${win_array[$cur_win_i]}"
        wmctrl -i -r "$win_id" -b remove,maximized_vert,maximized_horz
        xdotool windowsize "$win_id" "$w" "$sub_h"
        xdotool windowmove "$win_id" "$x" "$y"
        
        local nxt_y=$((y + sub_h))
        tile "$((cur_win_i + 1))" "$x" "$nxt_y" "$w" "$sub_h" "v"
    fi
}

cur_wrkspc=$(wmctrl -d | grep '*' | cut -d' ' -f1)

WORK_AREA=$(wmctrl -d | grep '*' | grep -oE 'WA: [0-9]+,[0-9]+ [0-9]+x[0-9]+')
WA_W=$(echo "$WORK_AREA" | awk '{print $3}' | cut -d'x' -f1)
WA_H=$(echo "$WORK_AREA" | awk '{print $3}' | cut -d'x' -f2)
WA_X=$(echo "$WORK_AREA" | awk '{print $2}' | cut -d' ' -f1 | cut -d',' -f1)
WA_Y=$(echo "$WORK_AREA" | awk '{print $2}' | cut -d' ' -f1 | cut -d',' -f2)

OPEN_WINS=$(wmctrl -l -x | awk -v ws="$cur_wrkspc" '$2 == ws && !( ($3 == "pcmanfm.Pcmanfm" && $5 == "pcmanfm") || ($3 == "plank.Plank" && $5 == "plank") || ($3 == "tint2.Tint2") ||  ($4 ~ /welcome-window|idle-window/) || ($3 == "xpenguins.Xpenguins") ) {print $1}')

OPEN_WINS_COUNT=$(echo "$OPEN_WINS" | grep -c .)

[ "$OPEN_WINS_COUNT" -eq 0 ] && exit 0

read -r -a win_array <<< "$(echo "$OPEN_WINS" | tr '\n' ' ')"

tile 0 "$WA_X" "$WA_Y" "$WA_W" "$WA_H" "v"
