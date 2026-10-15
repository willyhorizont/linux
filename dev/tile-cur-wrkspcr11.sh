#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    notify-send "tile-cur-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

half_q_w=401
LT_R_or_LB_R_w=$((half_q_w + 1))
RT_R_or_RB_R_x=$((half_q_w * 2))

WM_DATA=$(wmctrl -d | grep '*')
WORK_AREA=$(echo "$WM_DATA" | grep -oE 'WA: [0-9]+,[0-9]+ [0-9]+x[0-9]+')
WA_W=$(echo "$WORK_AREA" | awk '{print $3}' | cut -d'x' -f1)
WA_H=$(echo "$WORK_AREA" | awk '{print $3}' | cut -d'x' -f2)
WA_X=$(echo "$WORK_AREA" | awk '{print $2}' | cut -d' ' -f1 | cut -d',' -f1)
WA_Y=$(echo "$WORK_AREA" | awk '{print $2}' | cut -d' ' -f1 | cut -d',' -f2)
h_half=$(( WA_H / 2 ))

cur_wrkspc=$(echo "$WM_DATA" | awk '{print $1}')

OPEN_WINS=$(wmctrl -l -x | awk -v ws="$cur_wrkspc" '
$2 == ws {
    if ($3 == "pcmanfm.Pcmanfm" && $5 == "pcmanfm") next;
    if ($3 == "plank.Plank" && $5 == "plank") next;
    if ($3 == "tint2.Tint2") next;
    if ($3 == "xpenguins.Xpenguins") next;
    if ($4 ~ /welcome-window|idle-window/) next;
    print $1
}')

WIN_ARRAY=($OPEN_WINS)
WIN_COUNT=${#WIN_ARRAY[@]}

if [ "$WIN_COUNT" -eq 0 ]; then
    exit 0
fi

tile_win() {
    local wid=$1
    local x=$2
    local y=$3
    local w=$4
    local h=$5
    wmctrl -i -r "$wid" -b remove,maximized_vert,maximized_horz
    xdotool windowsize "$wid" "$w" "$h"
    xdotool windowmove "$wid" $((x + WA_X)) $((y + WA_Y))
}

case $WIN_COUNT in
    1)
        w=$(( (WA_W * 94) / 100 ))
        h=$(( (WA_H * 91) / 100 ))
        x=$(( (WA_W - w) / 2 ))
        y=$(( (WA_H - h) / 2 ))
        tile_win "${WIN_ARRAY[0]}" $x $y $w $h
        ;;
    2)
        # 2 win: L, R
        tile_win "${WIN_ARRAY[0]}" 0 0 $half_q_w $WA_H
        tile_win "${WIN_ARRAY[1]}" $half_q_w 0 $((WA_W - half_q_w)) $WA_H
        ;;
    3)
        # 3 win: L, RT, RB
        tile_win "${WIN_ARRAY[0]}" 0 0 $half_q_w $WA_H
        tile_win "${WIN_ARRAY[1]}" $half_q_w 0 $((WA_W - half_q_w)) $h_half
        tile_win "${WIN_ARRAY[2]}" $half_q_w $h_half $((WA_W - half_q_w)) $h_half
        ;;
    4)
        # 4 win: LT, LB, RT, RB
        tile_win "${WIN_ARRAY[0]}" 0 0 $half_q_w $h_half                             # LT
        tile_win "${WIN_ARRAY[1]}" 0 $h_half $half_q_w $h_half                       # LB
        tile_win "${WIN_ARRAY[2]}" $half_q_w 0 $((WA_W - half_q_w)) $h_half          # RT
        tile_win "${WIN_ARRAY[3]}" $half_q_w $h_half $((WA_W - half_q_w)) $h_half    # RB
        ;;
    5)
        # 5 win: LT, LB, RT, RB_L, RB_R
        tile_win "${WIN_ARRAY[0]}" 0 0 $half_q_w $h_half
        tile_win "${WIN_ARRAY[1]}" 0 $h_half $half_q_w $h_half
        tile_win "${WIN_ARRAY[2]}" $half_q_w 0 $((WA_W - half_q_w)) $h_half
        tile_win "${WIN_ARRAY[3]}" $half_q_w $h_half $LT_R_or_LB_R_w $h_half                  # RB_L
        tile_win "${WIN_ARRAY[4]}" $RT_R_or_RB_R_x $h_half $((WA_W - RT_R_or_RB_R_x)) $h_half # RB_R
        ;;
    6)
        # 6 win: LT, LB, RT_L, RT_R, RB_L, RB_R
        tile_win "${WIN_ARRAY[0]}" 0 0 $half_q_w $h_half
        tile_win "${WIN_ARRAY[1]}" 0 $h_half $half_q_w $h_half
        tile_win "${WIN_ARRAY[2]}" $half_q_w 0 $LT_R_or_LB_R_w $h_half                        # RT_L
        tile_win "${WIN_ARRAY[3]}" $RT_R_or_RB_R_x 0 $((WA_W - RT_R_or_RB_R_x)) $h_half       # RT_R
        tile_win "${WIN_ARRAY[4]}" $half_q_w $h_half $LT_R_or_LB_R_w $h_half                  # RB_L
        tile_win "${WIN_ARRAY[5]}" $RT_R_or_RB_R_x $h_half $((WA_W - RT_R_or_RB_R_x)) $h_half # RB_R
        ;;
    7)
        # 7 win: LT, LB_L, LB_R, RT_L, RT_R, RB_L, RB_R
        tile_win "${WIN_ARRAY[0]}" 0 0 $half_q_w $h_half
        # LB_L, LB_R
        w_left_sub=$((half_q_w / 2))
        tile_win "${WIN_ARRAY[1]}" 0 $h_half $w_left_sub $h_half
        tile_win "${WIN_ARRAY[2]}" $w_left_sub $h_half $((half_q_w - w_left_sub)) $h_half
        # RT_L, RT_R
        tile_win "${WIN_ARRAY[3]}" $half_q_w 0 $LT_R_or_LB_R_w $h_half
        tile_win "${WIN_ARRAY[4]}" $RT_R_or_RB_R_x 0 $((WA_W - RT_R_or_RB_R_x)) $h_half
        # RB_L, RB_R
        tile_win "${WIN_ARRAY[5]}" $half_q_w $h_half $LT_R_or_LB_R_w $h_half
        tile_win "${WIN_ARRAY[6]}" $RT_R_or_RB_R_x $h_half $((WA_W - RT_R_or_RB_R_x)) $h_half
        ;;
    8)
        # 8 win: LT_L, LT_R, LB_L, LB_R, RT_L, RT_R, RB_L, RB_R
        w_left_sub=$((half_q_w / 2))
        tile_win "${WIN_ARRAY[0]}" 0 0 $w_left_sub $h_half
        tile_win "${WIN_ARRAY[1]}" $w_left_sub 0 $((half_q_w - w_left_sub)) $h_half
        tile_win "${WIN_ARRAY[2]}" 0 $h_half $w_left_sub $h_half
        tile_win "${WIN_ARRAY[3]}" $w_left_sub $h_half $((half_q_w - w_left_sub)) $h_half
        tile_win "${WIN_ARRAY[4]}" $half_q_w 0 $LT_R_or_LB_R_w $h_half
        tile_win "${WIN_ARRAY[5]}" $half_q_w $h_half $LT_R_or_LB_R_w $h_half
        tile_win "${WIN_ARRAY[6]}" $RT_R_or_RB_R_x 0 $((WA_W - RT_R_or_RB_R_x)) $h_half
        tile_win "${WIN_ARRAY[7]}" $RT_R_or_RB_R_x $h_half $((WA_W - RT_R_or_RB_R_x)) $h_half
        ;;
    *)
        # >= 9 win: Fallback to layout 5 win with rest win stack
        tile_win "${WIN_ARRAY[0]}" 0 0 $half_q_w $h_half
        tile_win "${WIN_ARRAY[1]}" 0 $h_half $half_q_w $h_half
        tile_win "${WIN_ARRAY[2]}" $half_q_w 0 $((WA_W - half_q_w)) $h_half
        tile_win "${WIN_ARRAY[3]}" $half_q_w $h_half $LT_R_or_LB_R_w $h_half

        for ((i=4; i<WIN_COUNT; i++)); do
            tile_win "${WIN_ARRAY[i]}" $RT_R_or_RB_R_x $h_half $((WA_W - RT_R_or_RB_R_x)) $h_half
        done
        ;;
esac
