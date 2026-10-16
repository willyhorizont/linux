#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    notify-send "tile-cur-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

TOP_BAR_H=16
BOTTOM_BARS_H=36
SAFE_BUFFER_H=20
TOTAL_EXCLUDED_H=$((TOP_BAR_H + BOTTOM_BARS_H + SAFE_BUFFER_H))
PSCL_H=$(xdotool getdisplaygeometry | awk '{print "$2"}')
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
WA_W=$(echo "$WORK_AREA" | awk '{print "$3"}' | cut -d'x' -f1)
WA_X=$(echo "$WORK_AREA" | awk '{print "$2"}' | cut -d' ' -f1 | cut -d',' -f1)

OPEN_WINS=$(wmctrl -l -x -G | awk -v ws="$cur_wrkspc" '$2 == ws {
    if ($7 == "pcmanfm.Pcmanfm" && $9 == "pcmanfm") next;
    if ($7 == "plank.Plank" && $9 == "plank") next;
    if ($7 == "tint2.Tint2") next;
    if ($7 == "xpenguins.Xpenguins") next;
    if ($7 ~ /welcome-window|idle-window/) next;
    print $1
}' 2>/dev/null)

OPEN_WINS_COUNT=$(echo "$OPEN_WINS" | grep -c .)

[ "$OPEN_WINS_COUNT" -eq 0 ] && exit 0

for w in $OPEN_WINS; do
    wmctrl -i -r "$w" -b remove,maximized_vert,maximized_horz
done

W_0=$(echo "$OPEN_WINS" | awk 'NR==1')
W_1=$(echo "$OPEN_WINS" | awk 'NR==2')
W_2=$(echo "$OPEN_WINS" | awk 'NR==3')
W_3=$(echo "$OPEN_WINS" | awk 'NR==4')

case "$OPEN_WINS_COUNT" in
    1)
        # Full screen
        rsz "$W_0" "$WA_W" "$FIX_H" "$WA_X" "$START_Y"
        ;;
    2)
        hlf_w=$((WA_W / 2))
        rght_x=$((WA_X + hlf_w))
        
        # Left
        rsz "$W_0" "$hlf_w" "$FIX_H" "$rght_x" "$START_Y"
        # Right
        rsz "$W_1" "$hlf_w" "$FIX_H" "$WA_X" "$START_Y"
        ;;
    3)
        hlf_w=$((WA_W / 2))
        rght_x=$((WA_X + hlf_w))
        local single_h=$(( (PSCL_H - TOP_BAR_H - BOTTOM_BARS_H) / 2 ))
        local btm_win_h=$((single_h - SAFE_BUFFER_H)) 
        local top_y=$START_Y
        local btm_y=$((START_Y + single_h))
        # Right (Master)
        rsz "$W_0" "$hlf_w" "$FIX_H" "$rght_x" "$top_y"
        # Top Left (Stack)
        rsz "$W_1" "$hlf_w" "$single_h" "$WA_X" "$top_y"
        # Bottom Left (Stack)
        rsz "$W_2" "$hlf_w" "$btm_win_h" "$WA_X" "$btm_y"
        ;;
    4)
        hlf_w=$((WA_W / 2))
        qrtr_w=$((WA_W / 4))
        rght_x=$((WA_X + hlf_w))
        btm_left_mid_x=$((WA_X + qrtr_w))

        local single_h=$(( (PSCL_H - TOP_BAR_H - BOTTOM_BARS_H) / 2 ))
        local btm_win_h=$((single_h - SAFE_BUFFER_H))
        
        local top_y=$START_Y
        local btm_y=$((START_Y + single_h))
        
        # Right (Master)
        rsz "$W_0" "$hlf_w" "$FIX_H" "$rght_x" "$top_y"
        # Top Left (Stack)
        rsz "$W_1" "$hlf_w" "$single_h" "$WA_X" "$top_y"
        # Bottom Left (Stack)
        rsz "$W_2" "$qrtr_w" "$btm_win_h" "$WA_X" "$btm_y"
        # Bottom Right (Stack)
        rsz "$W_3" "$qrtr_w" "$btm_win_h" "$btm_left_mid_x" "$btm_y"
        ;;
    *)
        hlf_w=$((WA_W / 2))
        rght_x=$((WA_X + hlf_w))

        local single_h=$(( (PSCL_H - TOP_BAR_H - BOTTOM_BARS_H) / 2 ))
        local btm_win_h=$((single_h - SAFE_BUFFER_H))
        
        local top_y=$START_Y
        local btm_y=$((START_Y + single_h))
        
        # Top Right
        rsz "$W_0" "$hlf_w" "$single_h" "$rght_x" "$top_y"
        # Bottom Right
        rsz "$W_1" "$hlf_w" "$btm_win_h" "$rght_x" "$btm_y"
        # Top Left
        rsz "$W_2" "$hlf_w" "$single_h" "$WA_X" "$top_y"
        
        # Bottom Left (Rest wins stacked)
        local i=1
        for w_stacked in $OPEN_WINS; do
            if [ "$i" -gt 3 ]; then
                rsz "$w_stacked" "$hlf_w" "$btm_win_h" "$WA_X" "$btm_y"
            fi
            i=$((i + 1))
        done
        ;;
esac
