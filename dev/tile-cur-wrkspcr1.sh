#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    notify-send "tile-cur-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

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

case "$OPEN_WINS_COUNT" in
    1)
        # Full screen
        win_id="${win_array[0]}"
        wmctrl -i -r "$win_id" -b remove,maximized_vert,maximized_horz
        xdotool windowsize "$win_id" "$WA_W" "$WA_H"
        xdotool windowmove "$win_id" "$WA_X" "$WA_Y"
        ;;
    2)
        hlf_w=$((WA_W / 2))
        
        # Left
        wmctrl -i -r "${win_array[0]}" -b remove,maximized_vert,maximized_horz
        xdotool windowsize "${win_array[0]}" "$hlf_w" "$WA_H"
        xdotool windowmove "${win_array[0]}" "$WA_X" "$WA_Y"
        
        # Right
        rght_x=$((WA_X + hlf_w))
        wmctrl -i -r "${win_array[1]}" -b remove,maximized_vert,maximized_horz
        xdotool windowsize "${win_array[1]}" "$hlf_w" "$WA_H"
        xdotool windowmove "${win_array[1]}" "$rght_x" "$WA_Y"
        ;;
        
    3)
        hlf_w=$((WA_W / 2))
        hlf_h=$((WA_H / 2))
        rght_x=$((WA_X + hlf_w))
        btm_y=$((WA_Y + hlf_h))
        
        # Left (Master)
        wmctrl -i -r "${win_array[0]}" -b remove,maximized_vert,maximized_horz
        xdotool windowsize "${win_array[0]}" "$hlf_w" "$WA_H"
        xdotool windowmove "${win_array[0]}" "$WA_X" "$WA_Y"
        
        # Top Right (Stack)
        wmctrl -i -r "${win_array[1]}" -b remove,maximized_vert,maximized_horz
        xdotool windowsize "${win_array[1]}" "$hlf_w" "$hlf_h"
        xdotool windowmove "${win_array[1]}" "$rght_x" "$WA_Y"
        
        # Bottom Right (Stack)
        wmctrl -i -r "${win_array[2]}" -b remove,maximized_vert,maximized_horz
        xdotool windowsize "${win_array[2]}" "$hlf_w" "$hlf_h"
        xdotool windowmove "${win_array[2]}" "$rght_x" "$btm_y"
        ;;
        
    *)
        hlf_w=$((WA_W / 2))
        hlf_h=$((WA_H / 2))
        rght_x=$((WA_X + hlf_w))
        btm_y=$((WA_Y + hlf_h))
        
        for w in "${win_array[@]}"; do
            wmctrl -i -r "$w" -b remove,maximized_vert,maximized_horz
        done
        
        # Top-Left
        xdotool windowsize "${win_array[0]}" "$hlf_w" "$hlf_h" && xdotool windowmove "${win_array[0]}" "$WA_X" "$WA_Y"
        # Top-Right
        xdotool windowsize "${win_array[1]}" "$hlf_w" "$hlf_h" && xdotool windowmove "${win_array[1]}" "$rght_x" "$WA_Y"
        # Bottom-Left
        xdotool windowsize "${win_array[2]}" "$hlf_w" "$hlf_h" && xdotool windowmove "${win_array[2]}" "$WA_X" "$btm_y"
        # Bottom-Right (Rest wins stacked)
        for ((i=3; i<OPEN_WINS_COUNT; i++)); do
            xdotool windowsize "${win_array[$i]}" "$hlf_w" "$hlf_h"
            xdotool windowmove "${win_array[$i]}" "$rght_x" "$btm_y"
        done
        ;;
esac
