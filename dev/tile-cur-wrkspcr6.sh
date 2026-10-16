#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null || ! command -v xwininfo &> /dev/null; then
    notify-send "tile-cur-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool xwininfo'..."
    exit 1
fi

TOP_BAR_H=16
MY_SUBTRCT_H=$((TOP_BAR_H + 36))
PSCL_H=$(xdotool getdisplaygeometry | awk '{print $2}')
FIX_H=$((PSCL_H - MY_SUBTRCT_H))
START_Y=$TOP_BAR_H

rsz() {
    local win_id="$1"
    local trgt_w="$2"
    local trgt_h="$3"
    local trgt_x="$4"
    local trgt_y="$5"

    wmctrl -i -r "$win_id" -b remove,maximized_vert,maximized_horz
    xdotool windowsize "$win_id" "$trgt_w" "$trgt_h"
    xdotool windowmove "$win_id" "$trgt_x" "$trgt_y"

    sleep 0.02

    local cur_win_nfo
    cur_win_nfo=$(xwininfo -id "$win_id" 2>/dev/null)
    [ -z "$cur_win_nfo" ] && return 0

    local actual_w
    local actual_h
    actual_w=$(echo "$cur_win_nfo" | grep -i "Width:" | awk '{print $2}')
    actual_h=$(echo "$cur_win_nfo" | grep -i "Height:" | awk '{print $2}')

    local new_w="$trgt_w"
    local new_h="$trgt_h"

    if [ "$actual_w" -gt "$trgt_w" ]; then
        local border_w=$((actual_w - trgt_w))
        new_w=$((trgt_w - border_w))
    fi

    if [ "$actual_h" -gt "$trgt_h" ]; then
        local border_h=$((actual_h - trgt_h))
        new_h=$((trgt_h - border_h))
    fi

    if [ "$new_w" -ne "$trgt_w" ] || [ "$new_h" -ne "$trgt_h" ]; then
        xdotool windowsize "$win_id" "$new_w" "$new_h"
        xdotool windowmove "$win_id" "$trgt_x" "$trgt_y"
    fi
}

tile() {
    local cur_win_i=$1
    local x=$2; local y=$3
    local w=$4; local h=$5
    local o=$6

    if [ "$cur_win_i" -eq "$((OPEN_WINS_COUNT - 1))" ]; then
        local win_id="${win_array[$cur_win_i]}"
        rsz "$win_id" "$w" "$h" "$x" "$y"
        return 0
    fi

    if [ "$o" = "v" ]; then
        local sub_w=$((w / 2))
        local rght_x=$((x + sub_w))
        
        local win_id="${win_array[$cur_win_i]}"
        rsz "$win_id" "$sub_w" "$h" "$rght_x" "$y"
        
        tile "$((cur_win_i + 1))" "$x" "$y" "$sub_w" "$h" "h"
    else
        local sub_h=$((h / 2))
        
        local win_id="${win_array[$cur_win_i]}"
        rsz "$win_id" "$w" "$sub_h" "$x" "$y"
        
        local nxt_y=$((y + sub_h))
        tile "$((cur_win_i + 1))" "$x" "$nxt_y" "$w" "$sub_h" "v"
    fi
}

cur_wrkspc=$(wmctrl -d | grep '*' | cut -d' ' -f1)

WORK_AREA=$(wmctrl -d | grep '*' | grep -oE 'WA: [0-9]+,[0-9]+ [0-9]+x[0-9]+')
WA_W=$(echo "$WORK_AREA" | awk '{print $3}' | cut -d'x' -f1)
WA_X=$(echo "$WORK_AREA" | awk '{print $2}' | cut -d' ' -f1 | cut -d',' -f1)

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

read -r -a win_array <<< "$(echo "$OPEN_WINS" | tr '\n' ' ')"

tile 0 "$WA_X" "$START_Y" "$WA_W" "$FIX_H" "v"
