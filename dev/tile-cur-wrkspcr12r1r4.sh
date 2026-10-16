#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    notify-send "tile-cur-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

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
    local kb=$2
    xdotool windowactivate --sync "$wid"
    xdotool key "$kb"
}

LT="ctrl+super+q"          # C-W-q
LT_L="ctrl+super+shift+q"  # C-W-S-q
LT_R="ctrl+super+shift+1"  # C-W-S-1
LB="ctrl+super+a"          # C-W-a
LB_L="ctrl+super+shift+a"  # C-W-S-a
LB_R="ctrl+super+shift+z"  # C-W-S-z
RT="ctrl+super+w"          # C-W-w
RT_L="ctrl+super+shift+2"  # C-W-S-2
RT_R="ctrl+super+shift+w"  # C-W-S-w
RB="ctrl+super+s"          # C-W-s
RB_L="ctrl+super+shift+x"  # C-W-S-x
RB_R="ctrl+super+shift+s"  # C-W-S-s
CG="ctrl+super+g"          # C-W-g
F="ctrl+super+f"           # C-W-f
L="ctrl+super+Left"        # C-W-Left
R="ctrl+super+Right"       # C-W-Right

case $WIN_COUNT in
    1)
        tile_win "${WIN_ARRAY[0]}" "$F"
        ;;
    2)
        tile_win "${WIN_ARRAY[0]}" "$L"
        tile_win "${WIN_ARRAY[1]}" "$R"
        ;;
    3)
        tile_win "${WIN_ARRAY[0]}" "$L"
        tile_win "${WIN_ARRAY[1]}" "$RT"
        tile_win "${WIN_ARRAY[2]}" "$RB"
        ;;
    4)
        tile_win "${WIN_ARRAY[0]}" "$LT"
        tile_win "${WIN_ARRAY[1]}" "$LB"
        tile_win "${WIN_ARRAY[2]}" "$RT"
        tile_win "${WIN_ARRAY[3]}" "$RB"
        ;;
    5)
        tile_win "${WIN_ARRAY[0]}" "$LT"
        tile_win "${WIN_ARRAY[1]}" "$LB"
        tile_win "${WIN_ARRAY[2]}" "$RT"
        tile_win "${WIN_ARRAY[3]}" "$RB_L"
        tile_win "${WIN_ARRAY[4]}" "$RB_R"
        ;;
    6)
        tile_win "${WIN_ARRAY[0]}" "$LT"
        tile_win "${WIN_ARRAY[1]}" "$LB"
        tile_win "${WIN_ARRAY[2]}" "$RT_L"
        tile_win "${WIN_ARRAY[3]}" "$RT_R"
        tile_win "${WIN_ARRAY[4]}" "$RB_L"
        tile_win "${WIN_ARRAY[5]}" "$RB_R"
        ;;
    7)
        tile_win "${WIN_ARRAY[0]}" "$LT"
        tile_win "${WIN_ARRAY[1]}" "$LB_L"
        tile_win "${WIN_ARRAY[2]}" "$LB_R"
        tile_win "${WIN_ARRAY[3]}" "$RT_L"
        tile_win "${WIN_ARRAY[4]}" "$RT_R"
        tile_win "${WIN_ARRAY[5]}" "$RB_L"
        tile_win "${WIN_ARRAY[6]}" "$RB_R"
        ;;
    8)
        tile_win "${WIN_ARRAY[0]}" "$LT_L"
        tile_win "${WIN_ARRAY[1]}" "$LT_R"
        tile_win "${WIN_ARRAY[2]}" "$LB_L"
        tile_win "${WIN_ARRAY[3]}" "$LB_R"
        tile_win "${WIN_ARRAY[4]}" "$RT_L"
        tile_win "${WIN_ARRAY[5]}" "$RT_R"
        tile_win "${WIN_ARRAY[6]}" "$RB_L"
        tile_win "${WIN_ARRAY[7]}" "$RB_R"
        ;;
    *)
        tile_win "${WIN_ARRAY[0]}" "$LT"
        tile_win "${WIN_ARRAY[1]}" "$LB"
        tile_win "${WIN_ARRAY[2]}" "$RB_R"
        tile_win "${WIN_ARRAY[3]}" "$RB_L"
        for ((i=4; i<WIN_COUNT; i++)); do
            tile_win "${WIN_ARRAY[i]}" "$RT"
        done
        ;;
esac
