#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    notify-send "tile-cur-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

TOP_BAR_H=16
BOTTOM_BARS_H=36
SAFE_BUFFER_H=0
TOTAL_EXCLUDED_H=$((TOP_BAR_H + BOTTOM_BARS_H + SAFE_BUFFER_H))
PSCL_H=$(xdotool getdisplaygeometry | awk '{print $2}')
FIX_H=$((PSCL_H - TOTAL_EXCLUDED_H))
START_Y=$TOP_BAR_H

rsz() {
    local win_id="$1"
    local trgt_w="$2"
    local trgt_h="$3"
    local trgt_x="$4"
    local trgt_y="$5"

    xdotool windowsize "$win_id" "$trgt_w" "$trgt_h"
    xdotool windowmove "$win_id" "$trgt_x" "$trgt_y"

    sleep 0.01

    local actual_h
    actual_h=$(xdotool getwindowgeometry "$win_id" 2>/dev/null | grep -oE 'Geometry: [0-9]+x[0-9]+' | cut -d'x' -f2)

    if [ -n "$actual_h" ] && [ "$actual_h" -gt "$trgt_h" ]; then
        local delta=$((actual_h - trgt_h))
        local correct_h=$((trgt_h - delta))
        
        xdotool windowsize "$win_id" "$trgt_w" "$correct_h"
        xdotool windowmove "$win_id" "$trgt_x" "$trgt_y"
    fi
}

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
        rsz "${win_array[0]}" "$WA_W" "$FIX_H" "$WA_X" "$START_Y"
        ;;
    2)
        hlf_w=$((WA_W / 2))
        rght_x=$((WA_X + hlf_w))
        
        # Left
        rsz "${win_array[0]}" "$hlf_w" "$FIX_H" "$rght_x" "$START_Y"
        # Right
        rsz "${win_array[1]}" "$hlf_w" "$FIX_H" "$WA_X" "$START_Y"
        ;;
    3)
        hlf_w=$((WA_W / 2))
        hlf_h=$((FIX_H / 2))
        rght_x=$((WA_X + hlf_w))
        btm_y=$((START_Y + hlf_h))
        
        # Right (Master)
        rsz "${win_array[0]}" "$hlf_w" "$FIX_H" "$rght_x" "$START_Y"
        # Top Left (Stack)
        rsz "${win_array[1]}" "$hlf_w" "$hlf_h" "$WA_X" "$START_Y"
        # Bottom Left (Stack)
        rsz "${win_array[2]}" "$hlf_w" "$hlf_h" "$WA_X" "$btm_y"
        ;;
    4)
        hlf_w=$((WA_W / 2))
        hlf_h=$((FIX_H / 2))
        qrtr_w=$((WA_W / 4))
        
        rght_x=$((WA_X + hlf_w))
        btm_y=$((START_Y + hlf_h))
        btm_left_mid_x=$((WA_X + qrtr_w))
        
        # Right (Master)
        rsz "${win_array[0]}" "$hlf_w" "$FIX_H" "$rght_x" "$START_Y"
        # Top Left (Stack)
        rsz "${win_array[1]}" "$hlf_w" "$hlf_h" "$WA_X" "$START_Y"
        # Bottom Left (Stack)
        rsz "${win_array[2]}" "$qrtr_w" "$hlf_h" "$WA_X" "$btm_y"
        # Bottom Right (Stack)
        rsz "${win_array[3]}" "$qrtr_w" "$hlf_h" "$btm_left_mid_x" "$btm_y"
        ;;
    *)
        hlf_w=$((WA_W / 2))
        hlf_h=$((FIX_H / 2))
        rght_x=$((WA_X + hlf_w))
        btm_y=$((START_Y + hlf_h))
        
        # Top Right
        rsz "${win_array[0]}" "$hlf_w" "$hlf_h" "$rght_x" "$START_Y"
        # Bottom Right
        rsz "${win_array[1]}" "$hlf_w" "$hlf_h" "$rght_x" "$btm_y"
        # Top Left
        rsz "${win_array[2]}" "$hlf_w" "$hlf_h" "$WA_X" "$START_Y"
        
        # Bottom Left (Rest wins stacked)
        for ((i=3; i<OPEN_WINS_COUNT; i++)); do
            rsz "${win_array[$i]}" "$hlf_w" "$hlf_h" "$WA_X" "$btm_y"
        done
        ;;
esac
