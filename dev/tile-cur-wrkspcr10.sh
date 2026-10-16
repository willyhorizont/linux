#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    notify-send "tile-cur-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

half_q_w=401 
LT_R_or_LB_R_w=$((half_q_w + 1))
RT_R_or_RB_R_w=$((half_q_w * 2))

SCREEN_W=$(xdotool getdisplaygeometry | awk '{print $1}')
SCREEN_H=$(xdotool getdisplaygeometry | awk '{print $2}')
h_half=$(( SCREEN_H / 2 ))

cur_wrkspc=$(wmctrl -d | grep '*' | awk '{print $1}')

OPEN_WINS=$(wmctrl -l -x | awk -v ws="$cur_wrkspc" '
$2 == ws {
    if ($3 == "pcmanfm.Pcmanfm" && $5 == "pcmanfm") next;
    if ($3 == "plank.Plank" && $5 == "plank") next;
    if ($3 == "tint2.Tint2") next;
    if ($3 == "xpenguins.Xpenguins") next;
    if ($3 ~ /welcome-window|idle-window/) next;
    print $1
}')

read -r -a WIN_ARRAY <<< "$OPEN_WINS"
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
    wmctrl -i -r "$wid" -e "0,$x,$y,$w,$h"
}

case $WIN_COUNT in
    1)
        # 1 win: CG (94% * 91%)
        w=$(( (SCREEN_W * 94) / 100 ))
        h=$(( (SCREEN_H * 91) / 100 ))
        x=$(( (SCREEN_W - w) / 2 ))
        y=$(( (SCREEN_H - h) / 2 ))
        tile_win "${WIN_ARRAY[0]}" $x $y $w $h
        ;;
        
    2)
        # 2 win: L, R (50%*100%)
        tile_win "${WIN_ARRAY[0]}" 0 0 $half_q_w $SCREEN_H
        tile_win "${WIN_ARRAY[1]}" $half_q_w 0 $((SCREEN_W - half_q_w)) $SCREEN_H
        ;;
        
    3)
        # 3 win: L (50%*100%), RT (50%*50%), RB (50%*50%)
        tile_win "${WIN_ARRAY[0]}" 0 0 $half_q_w $SCREEN_H
        tile_win "${WIN_ARRAY[1]}" $half_q_w 0 $((SCREEN_W - half_q_w)) $h_half
        tile_win "${WIN_ARRAY[2]}" $half_q_w $h_half $((SCREEN_W - half_q_w)) $h_half
        ;;
        
    4)
        # 4 win: LT, LB, RT, RB (All 50%*50%)
        tile_win "${WIN_ARRAY[0]}" 0 0 $half_q_w $h_half
        tile_win "${WIN_ARRAY[1]}" 0 $h_half $half_q_w $h_half
        tile_win "${WIN_ARRAY[2]}" $half_q_w 0 $((SCREEN_W - half_q_w)) $h_half
        tile_win "${WIN_ARRAY[3]}" $half_q_w $h_half $((SCREEN_W - half_q_w)) $h_half
        ;;
        
    5)
        # 5 win: LT, LB, RT (50%*50%), RB_L, RB_R (25%*50%)
        tile_win "${WIN_ARRAY[0]}" 0 0 $half_q_w $h_half
        tile_win "${WIN_ARRAY[1]}" 0 $h_half $half_q_w $h_half
        tile_win "${WIN_ARRAY[2]}" $half_q_w 0 $((SCREEN_W - half_q_w)) $h_half

        # RB_L, RB_R (25%*50%)
        tile_win "${WIN_ARRAY[3]}" $half_q_w $h_half $LT_R_or_LB_R_w $h_half
        x_next=$((half_q_w + LT_R_or_LB_R_w))
        tile_win "${WIN_ARRAY[4]}" $x_next $h_half $((SCREEN_W - x_next)) $h_half
        ;;

    6)
        # 6 win: LT, LB (50%*50%), RT_L, RT_R, RB_L, RB_R (25%*50%)
        tile_win "${WIN_ARRAY[0]}" 0 0 $half_q_w $h_half
        tile_win "${WIN_ARRAY[1]}" 0 $h_half $half_q_w $h_half

        # RT_L, RT_R
        tile_win "${WIN_ARRAY[2]}" $half_q_w 0 $LT_R_or_LB_R_w $h_half
        x_next=$((half_q_w + LT_R_or_LB_R_w))
        tile_win "${WIN_ARRAY[3]}" $x_next 0 $((SCREEN_W - x_next)) $h_half

        # RB_L, RB_R
        tile_win "${WIN_ARRAY[4]}" $half_q_w $h_half $LT_R_or_LB_R_w $h_half
        tile_win "${WIN_ARRAY[5]}" $x_next $h_half $((SCREEN_W - x_next)) $h_half
        ;;

    7)
        # 7 win: LT (50%*50%), LB_L, LB_R, RT_L, RT_R, RB_L, RB_R (25%*50%)
        tile_win "${WIN_ARRAY[0]}" 0 0 $half_q_w $h_half

        # LB_L, LB_R
        w_left_sub=$((half_q_w / 2))
        tile_win "${WIN_ARRAY[1]}" 0 $h_half $w_left_sub $h_half
        tile_win "${WIN_ARRAY[2]}" $w_left_sub $h_half $((half_q_w - w_left_sub)) $h_half

        # RT_L, RT_R
        tile_win "${WIN_ARRAY[3]}" $half_q_w 0 $LT_R_or_LB_R_w $h_half
        x_next=$((half_q_w + LT_R_or_LB_R_w))
        tile_win "${WIN_ARRAY[4]}" $x_next 0 $((SCREEN_W - x_next)) $h_half

        # RB_L, RB_R
        tile_win "${WIN_ARRAY[5]}" $half_q_w $h_half $LT_R_or_LB_R_w $h_half
        tile_win "${WIN_ARRAY[6]}" $x_next $h_half $((SCREEN_W - x_next)) $h_half
        ;;

    8)
        # 8 win: LT_L, LT_R, LB_L, LB_R, RT_L, RT_R, RB_L, RB_R (25%*50%)
        w_left_sub=$((half_q_w / 2))
        # LT_L, LT_R
        tile_win "${WIN_ARRAY[0]}" 0 0 $w_left_sub $h_half
        tile_win "${WIN_ARRAY[1]}" $w_left_sub 0 $((half_q_w - w_left_sub)) $h_half
        # LB_L, LB_R
        tile_win "${WIN_ARRAY[2]}" 0 $h_half $w_left_sub $h_half
        tile_win "${WIN_ARRAY[3]}" $w_left_sub $h_half $((half_q_w - w_left_sub)) $h_half
        # RT_L, RT_R
        tile_win "${WIN_ARRAY[4]}" $half_q_w 0 $LT_R_or_LB_R_w $h_half
        x_next=$((half_q_w + LT_R_or_LB_R_w))
        tile_win "${WIN_ARRAY[5]}" $x_next 0 $((SCREEN_W - x_next)) $h_half
        # RB_L, RB_R
        tile_win "${WIN_ARRAY[6]}" $half_q_w $h_half $LT_R_or_LB_R_w $h_half
        tile_win "${WIN_ARRAY[7]}" $x_next $h_half $((SCREEN_W - x_next)) $h_half
        ;;

    *)
        # >= 9 win: Fallback to layout 5 win with rest win stack
        tile_win "${WIN_ARRAY[0]}" 0 0 $half_q_w $h_half
        tile_win "${WIN_ARRAY[1]}" 0 $h_half $half_q_w $h_half
        tile_win "${WIN_ARRAY[2]}" $half_q_w 0 $((SCREEN_W - half_q_w)) $h_half

        tile_win "${WIN_ARRAY[3]}" $half_q_w $h_half $LT_R_or_LB_R_w $h_half
        x_next=$((half_q_w + LT_R_or_LB_R_w))

        # Rest win stack
        for ((i=4; i<WIN_COUNT; i++)); do
            tile_win "${WIN_ARRAY[i]}" $x_next $h_half $((SCREEN_W - x_next)) $h_half
        done
        ;;
esac
