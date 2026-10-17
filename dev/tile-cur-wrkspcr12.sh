#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    notify-send "kb-tile-cur-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

CONF_FILE="$HOME/willyhorizont.github.io/.config/tile.conf"

if [ ! -f "$CONF_FILE" ]; then
    notify-send "kb-tile-cur-wrkspc.sh" "Error: $CONF_FILE not found"
    exit 1
fi

get_geom() {
    local k=$1
    echo $(grep "^${k}[[:space:]]*=" "$CONF_FILE" | sed 's/=//g' | awk '{$1=""; print $0}')
}

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

WIN_ARRAY=($OPEN_WINS)
WIN_COUNT=${#WIN_ARRAY[@]}

if [ "$WIN_COUNT" -eq 0 ]; then
    exit 0
fi

tile_win() {
    local wid=$1
    local k=$2
    local geom=$(get_geom "$k")
    local c_ls=($geom)
    local x=${c_ls[0]}
    local y=${c_ls[1]}
    local w=${c_ls[2]}
    local h=${c_ls[3]}
    if [ -z "$x" ] || [ -z "$y" ] || [ -z "$w" ] || [ -z "$h" ]; then
        notify-send "kb-tile-cur-wrkspc.sh" "Error: Invalid $CONF_FILE"
        return 1
    fi
    WIN_NM=$(xdotool getwindowname "$wid" 2>/dev/null | cut -c1-30)
    notify-send "[dev] kb-tile-cur-wrkspc.sh" "tiling: $WIN_NM $x $y $w $h"
    wmctrl -i -r "$wid" -b remove,maximized_vert,maximized_horz
    xdotool windowsize "$wid" "$w" "$h"
    xdotool windowmove "$wid" "$x" "$y"
    echo "
[dev] kb-tile-cur-wrkspc.sh tiling: $WIN_NM
wmctrl -i -r $wid -b remove,maximized_vert,maximized_horz
xdotool windowsize $wid $w $h
xdotool windowmove $wid $x $y
"
}

case $WIN_COUNT in
    1)
        # 1 win: CG
        tile_win "${WIN_ARRAY[0]}" "CG"
        ;;
    2)
        # 2 win: L, R
        tile_win "${WIN_ARRAY[0]}" "L"
        tile_win "${WIN_ARRAY[1]}" "R"
        ;;
    3)
        # 3 win: L, RT, RB
        tile_win "${WIN_ARRAY[0]}" "L"
        tile_win "${WIN_ARRAY[1]}" "RT"
        tile_win "${WIN_ARRAY[2]}" "RB"
        ;;
    4)
        # 4 win: LT, LB, RT, RB
        tile_win "${WIN_ARRAY[0]}" "LT"
        tile_win "${WIN_ARRAY[1]}" "LB"
        tile_win "${WIN_ARRAY[2]}" "RT"
        tile_win "${WIN_ARRAY[3]}" "RB"
        ;;
    5)
        # 5 win: LT, LB, RT, RB_L, RB_R
        tile_win "${WIN_ARRAY[0]}" "LT"
        tile_win "${WIN_ARRAY[1]}" "LB"
        tile_win "${WIN_ARRAY[2]}" "RT"
        tile_win "${WIN_ARRAY[3]}" "RB_L"
        tile_win "${WIN_ARRAY[4]}" "RB_R"
        ;;
    6)
        # 6 win: LT, LB, RT_L, RT_R, RB_L, RB_R
        tile_win "${WIN_ARRAY[0]}" "LT"
        tile_win "${WIN_ARRAY[1]}" "LB"
        tile_win "${WIN_ARRAY[2]}" "RT_L"
        tile_win "${WIN_ARRAY[3]}" "RT_R"
        tile_win "${WIN_ARRAY[4]}" "RB_L"
        tile_win "${WIN_ARRAY[5]}" "RB_R"
        ;;
    7)
        # 7 win: LT, LB_L, LB_R, RT_L, RT_R, RB_L, RB_R
        tile_win "${WIN_ARRAY[0]}" "LT"
        tile_win "${WIN_ARRAY[1]}" "LB_L"
        tile_win "${WIN_ARRAY[2]}" "LB_R"
        tile_win "${WIN_ARRAY[3]}" "RT_L"
        tile_win "${WIN_ARRAY[4]}" "RT_R"
        tile_win "${WIN_ARRAY[5]}" "RB_L"
        tile_win "${WIN_ARRAY[6]}" "RB_R"
        ;;
    8)
        # 8 win: LT_L, LT_R, LB_L, LB_R, RT_L, RT_R, RB_L, RB_R
        tile_win "${WIN_ARRAY[0]}" "LT_L"
        tile_win "${WIN_ARRAY[1]}" "LT_R"
        tile_win "${WIN_ARRAY[2]}" "LB_L"
        tile_win "${WIN_ARRAY[3]}" "LB_R"
        tile_win "${WIN_ARRAY[4]}" "RT_L"
        tile_win "${WIN_ARRAY[5]}" "RT_R"
        tile_win "${WIN_ARRAY[6]}" "RB_L"
        tile_win "${WIN_ARRAY[7]}" "RB_R"
        ;;
    *)
        # >= 9 win: Default 5 win layout, Rest stack in RB_R
        tile_win "${WIN_ARRAY[0]}" "LT"
        tile_win "${WIN_ARRAY[1]}" "LB"
        tile_win "${WIN_ARRAY[2]}" "RT"
        tile_win "${WIN_ARRAY[3]}" "RB_L"
        for ((i=4; i<WIN_COUNT; i++)); do
            tile_win "${WIN_ARRAY[i]}" "RB_R"
        done
        ;;
esac
