#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    notify-send "tile-cur-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

TOP_BAR_H=16
MY_SUBTRCT_H=$((TOP_BAR_H + 36))
PSCL_H=$(xdotool getdisplaygeometry | awk '{print $2}')
FIX_H=$((PSCL_H - MY_SUBTRCT_H))
START_Y=$TOP_BAR_H

cur_wrkspc=$(wmctrl -d | grep '*' | cut -d' ' -f1)

WORK_AREA=$(wmctrl -d | grep '*' | grep -oE 'WA: [0-9]+,[0-9]+ [0-9]+x[0-9]+')
WA_W=$(echo "$WORK_AREA" | awk '{print $3}' | cut -d'x' -f1)
WA_X=$(echo "$WORK_AREA" | awk '{print $2}' | cut -d' ' -f1 | cut -d',' -f1)

OPEN_WINS=$(wmctrl -l -x | awk -v ws="$cur_wrkspc" '$2 == ws && !( ($3 == "pcmanfm.Pcmanfm" && $5 == "pcmanfm") || ($3 == "plank.Plank" && $5 == "plank") || ($3 == "tint2.Tint2") ||  ($4 ~ /welcome-window|idle-window/) || ($3 == "xpenguins.Xpenguins") ) {print $1}')

OPEN_WINS_COUNT=$(echo "$OPEN_WINS" | grep -c .)

[ "$OPEN_WINS_COUNT" -eq 0 ] && exit 0

read -r -a win_array <<< "$(echo "$OPEN_WINS" | tr '\n' ' ')"

for w in "${win_array[@]}"; do
    wmctrl -i -r "$w" -b remove,maximized_vert,maximized_horz
done

case "$OPEN_WINS_COUNT" in
    1)
        # Full screen
        xdotool windowsize "${win_array[0]}" "$WA_W" "$FIX_H"
        xdotool windowmove "${win_array[0]}" "$WA_X" "$START_Y"
        ;;
    2)
        hlf_w=$((WA_W / 2))
        rght_x=$((WA_X + hlf_w))
        
        # Left
        xdotool windowsize "${win_array[0]}" "$hlf_w" "$FIX_H"
        xdotool windowmove "${win_array[0]}" "$rght_x" "$START_Y"
        
        # Right
        xdotool windowsize "${win_array[1]}" "$hlf_w" "$FIX_H"
        xdotool windowmove "${win_array[1]}" "$WA_X" "$START_Y"
        ;;
    3)
        hlf_w=$((WA_W / 2))
        hlf_h=$((FIX_H / 2))
        rght_x=$((WA_X + hlf_w))
        btm_y=$((START_Y + hlf_h))
        
        # Right (Master)
        xdotool windowsize "${win_array[0]}" "$hlf_w" "$FIX_H"
        xdotool windowmove "${win_array[0]}" "$rght_x" "$START_Y"
        
        # Top Left (Stack)
        xdotool windowsize "${win_array[1]}" "$hlf_w" "$hlf_h"
        xdotool windowmove "${win_array[1]}" "$WA_X" "$START_Y"
        
        # Bottom Left (Stack)
        xdotool windowsize "${win_array[2]}" "$hlf_w" "$hlf_h"
        xdotool windowmove "${win_array[2]}" "$WA_X" "$btm_y"
        ;;
    4)
        hlf_w=$((WA_W / 2))
        hlf_h=$((FIX_H / 2))
        qrtr_w=$((WA_W / 4))
        
        rght_x=$((WA_X + hlf_w))
        btm_y=$((START_Y + hlf_h))
        btm_left_mid_x=$((WA_X + qrtr_w))
        
        # Right (Master)
        xdotool windowsize "${win_array[0]}" "$hlf_w" "$FIX_H"
        xdotool windowmove "${win_array[0]}" "$rght_x" "$START_Y"
        
        # Top Left (Stack)
        xdotool windowsize "${win_array[1]}" "$hlf_w" "$hlf_h"
        xdotool windowmove "${win_array[1]}" "$WA_X" "$START_Y"
        
        # Bottom Left (Stack)
        xdotool windowsize "${win_array[2]}" "$qrtr_w" "$hlf_h"
        xdotool windowmove "${win_array[2]}" "$WA_X" "$btm_y"
        
        # Bottom Right (Stack)
        xdotool windowsize "${win_array[3]}" "$qrtr_w" "$hlf_h"
        xdotool windowmove "${win_array[3]}" "$btm_left_mid_x" "$btm_y"
        ;;
    *)
        hlf_w=$((WA_W / 2))
        hlf_h=$((FIX_H / 2))
        rght_x=$((WA_X + hlf_w))
        btm_y=$((START_Y + hlf_h))
        
        # Top Right
        xdotool windowsize "${win_array[0]}" "$hlf_w" "$hlf_h" && xdotool windowmove "${win_array[0]}" "$rght_x" "$START_Y"
        # Bottom Right
        xdotool windowsize "${win_array[1]}" "$hlf_w" "$hlf_h" && xdotool windowmove "${win_array[1]}" "$rght_x" "$btm_y"
        # Top Left
        xdotool windowsize "${win_array[2]}" "$hlf_w" "$hlf_h" && xdotool windowmove "${win_array[2]}" "$WA_X" "$START_Y"
        # Bottom Left (Rest wins stacked)
        for ((i=3; i<OPEN_WINS_COUNT; i++)); do
            xdotool windowsize "${win_array[$i]}" "$hlf_w" "$hlf_h"
            xdotool windowmove "${win_array[$i]}" "$WA_X" "$btm_y"
        done
        ;;
esac
