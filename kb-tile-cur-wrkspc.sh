#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    notify-send "kb-tile-cur-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

cur_wrkspc=$(wmctrl -d | grep '*' | awk '{print $1}')
OPEN_WINS=$(wmctrl -l -x -G | awk -v ws="$cur_wrkspc" '$2 == ws {
    if ($7 == "pcmanfm.Pcmanfm" && $9 == "pcmanfm") next;
    if ($7 == "plank.Plank" && $9 == "plank") next;
    if ($7 == "tint2.Tint2") next;
    if ($7 == "xpenguins.Xpenguins") next;
    if ($7 ~ /welcome-window|idle-window/) next;
    print $1
}' 2>/dev/null)

WIN_ARRAY=($OPEN_WINS)
WIN_COUNT=${#WIN_ARRAY[@]}

if [ "$WIN_COUNT" -eq 0 ]; then
    exit 0
fi

tile_win() {
    local wid=$1
    local kb=$2
    wmctrl -i -r "$wid" -b remove,maximized_vert,maximized_horz
    # xdotool windowactivate --sync "$wid"
    wmctrl -i -a "$wid"
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
T="ctrl+super+Up"          # C-W-Up
B="ctrl+super+Down"        # C-W-Down

CYCLE_FILE="/tmp/tile_cycle_ws_${cur_wrkspc}_wins_${WIN_COUNT}.state"

cur_cy=$(cat "$CYCLE_FILE" 2>/dev/null)
cur_cy=${cur_cy:-1}

case $WIN_COUNT in
    1)
        case $cur_cy in
            1)
                tile_win "${WIN_ARRAY[0]}" "$F"
                next_cycle=2
                ;;
            2)
                tile_win "${WIN_ARRAY[0]}" "$CG"
                next_cycle=1
                ;;
            *)
                tile_win "${WIN_ARRAY[0]}" "$F"
                next_cycle=2
                ;;
        esac
        echo "$next_cycle" > "$CYCLE_FILE"
        ;;
    2)
        case $cur_cy in
            1)
                tile_win "${WIN_ARRAY[0]}" "$L"
                tile_win "${WIN_ARRAY[1]}" "$R"
                next_cycle=2
                ;;
            2)
                tile_win "${WIN_ARRAY[0]}" "$T"
                tile_win "${WIN_ARRAY[1]}" "$B"
                next_cycle=1
                ;;
            *)
                tile_win "${WIN_ARRAY[0]}" "$L"
                tile_win "${WIN_ARRAY[1]}" "$R"
                next_cycle=2
                ;;
        esac
        echo "$next_cycle" > "$CYCLE_FILE"
        ;;
    3)
        case $cur_cy in
            1)
                tile_win "${WIN_ARRAY[0]}" "$L"
                tile_win "${WIN_ARRAY[1]}" "$RT"
                tile_win "${WIN_ARRAY[2]}" "$RB"
                next_cycle=2
                ;;
            2)
                tile_win "${WIN_ARRAY[0]}" "$R"
                tile_win "${WIN_ARRAY[1]}" "$LT"
                tile_win "${WIN_ARRAY[2]}" "$LB"
                next_cycle=3
                ;;
            3)
                tile_win "${WIN_ARRAY[0]}" "$T"
                tile_win "${WIN_ARRAY[1]}" "$LB"
                tile_win "${WIN_ARRAY[2]}" "$RB"
                next_cycle=4
                ;;
            4)
                tile_win "${WIN_ARRAY[0]}" "$B"
                tile_win "${WIN_ARRAY[1]}" "$LT"
                tile_win "${WIN_ARRAY[2]}" "$RT"
                next_cycle=1
                ;;
            *)
                tile_win "${WIN_ARRAY[0]}" "$L"
                tile_win "${WIN_ARRAY[1]}" "$RT"
                tile_win "${WIN_ARRAY[2]}" "$RB"
                next_cycle=2
                ;;
        esac
        echo "$next_cycle" > "$CYCLE_FILE"
        ;;
    4)
        case $cur_cy in
            1)
                tile_win "${WIN_ARRAY[0]}" "$LT"
                tile_win "${WIN_ARRAY[1]}" "$LB"
                tile_win "${WIN_ARRAY[2]}" "$RT"
                tile_win "${WIN_ARRAY[3]}" "$RB"
                next_cycle=2
                ;;
            2)
                tile_win "${WIN_ARRAY[0]}" "$L"
                tile_win "${WIN_ARRAY[1]}" "$RT"
                tile_win "${WIN_ARRAY[2]}" "$RB_L"
                tile_win "${WIN_ARRAY[3]}" "$RB_R"
                next_cycle=3
                ;;
            3)
                tile_win "${WIN_ARRAY[0]}" "$L"
                tile_win "${WIN_ARRAY[1]}" "$RB"
                tile_win "${WIN_ARRAY[2]}" "$RT_L"
                tile_win "${WIN_ARRAY[3]}" "$RT_R"
                next_cycle=4
                ;;
            4)
                tile_win "${WIN_ARRAY[0]}" "$R"
                tile_win "${WIN_ARRAY[1]}" "$LT"
                tile_win "${WIN_ARRAY[2]}" "$LB_L"
                tile_win "${WIN_ARRAY[3]}" "$LB_R"
                next_cycle=5
                ;;
            5)
                tile_win "${WIN_ARRAY[0]}" "$R"
                tile_win "${WIN_ARRAY[1]}" "$LB"
                tile_win "${WIN_ARRAY[2]}" "$LT_L"
                tile_win "${WIN_ARRAY[3]}" "$LT_R"
                next_cycle=6
                ;;
            6)
                tile_win "${WIN_ARRAY[0]}" "$T"
                tile_win "${WIN_ARRAY[1]}" "$LB"
                tile_win "${WIN_ARRAY[2]}" "$RB_L"
                tile_win "${WIN_ARRAY[3]}" "$RB_R"
                next_cycle=7
                ;;
            7)
                tile_win "${WIN_ARRAY[0]}" "$T"
                tile_win "${WIN_ARRAY[1]}" "$RB"
                tile_win "${WIN_ARRAY[2]}" "$LB_L"
                tile_win "${WIN_ARRAY[3]}" "$LB_R"
                next_cycle=8
                ;;
            8)
                tile_win "${WIN_ARRAY[0]}" "$B"
                tile_win "${WIN_ARRAY[1]}" "$LT"
                tile_win "${WIN_ARRAY[2]}" "$RT_L"
                tile_win "${WIN_ARRAY[3]}" "$RT_R"
                next_cycle=9
                ;;
            9)
                tile_win "${WIN_ARRAY[0]}" "$B"
                tile_win "${WIN_ARRAY[1]}" "$RT"
                tile_win "${WIN_ARRAY[2]}" "$LT_L"
                tile_win "${WIN_ARRAY[3]}" "$LT_R"
                next_cycle=1
                ;;
            *)
                tile_win "${WIN_ARRAY[0]}" "$LT"
                tile_win "${WIN_ARRAY[1]}" "$LB"
                tile_win "${WIN_ARRAY[2]}" "$RT"
                tile_win "${WIN_ARRAY[3]}" "$RB"
                next_cycle=2
                ;;
        esac
        echo "$next_cycle" > "$CYCLE_FILE"
        ;;
    5)
        case $cur_cy in
            1)
                tile_win "${WIN_ARRAY[0]}" "$LT"
                tile_win "${WIN_ARRAY[1]}" "$LB"
                tile_win "${WIN_ARRAY[2]}" "$RT"
                tile_win "${WIN_ARRAY[3]}" "$RB_L"
                tile_win "${WIN_ARRAY[4]}" "$RB_R"
                next_cycle=2
                ;;
            2)
                tile_win "${WIN_ARRAY[0]}" "$LT"
                tile_win "${WIN_ARRAY[1]}" "$LB_L"
                tile_win "${WIN_ARRAY[2]}" "$LB_R"
                tile_win "${WIN_ARRAY[3]}" "$RT"
                tile_win "${WIN_ARRAY[4]}" "$RB"
                next_cycle=3
                ;;
            3)
                tile_win "${WIN_ARRAY[0]}" "$LT"
                tile_win "${WIN_ARRAY[1]}" "$LB"
                tile_win "${WIN_ARRAY[2]}" "$RT_L"
                tile_win "${WIN_ARRAY[3]}" "$RT_R"
                tile_win "${WIN_ARRAY[4]}" "$RB"
                next_cycle=4
                ;;
            4)
                tile_win "${WIN_ARRAY[0]}" "$LT_L"
                tile_win "${WIN_ARRAY[1]}" "$LT_R"
                tile_win "${WIN_ARRAY[2]}" "$LB"
                tile_win "${WIN_ARRAY[3]}" "$RT"
                tile_win "${WIN_ARRAY[4]}" "$RB"
                next_cycle=5
                ;;
            5)
                tile_win "${WIN_ARRAY[0]}" "$L"
                tile_win "${WIN_ARRAY[1]}" "$RT_L"
                tile_win "${WIN_ARRAY[2]}" "$RT_R"
                tile_win "${WIN_ARRAY[3]}" "$RB_L"
                tile_win "${WIN_ARRAY[4]}" "$RB_R"
                next_cycle=6
                ;;
            6)
                tile_win "${WIN_ARRAY[0]}" "$R"
                tile_win "${WIN_ARRAY[1]}" "$LT_L"
                tile_win "${WIN_ARRAY[2]}" "$LT_R"
                tile_win "${WIN_ARRAY[3]}" "$LB_L"
                tile_win "${WIN_ARRAY[4]}" "$LB_R"
                next_cycle=7
                ;;
            7)
                tile_win "${WIN_ARRAY[0]}" "$T"
                tile_win "${WIN_ARRAY[1]}" "$LB_L"
                tile_win "${WIN_ARRAY[2]}" "$LB_R"
                tile_win "${WIN_ARRAY[3]}" "$RB_L"
                tile_win "${WIN_ARRAY[4]}" "$RB_R"
                next_cycle=8
                ;;
            8)
                tile_win "${WIN_ARRAY[0]}" "$B"
                tile_win "${WIN_ARRAY[1]}" "$LT_L"
                tile_win "${WIN_ARRAY[2]}" "$LT_R"
                tile_win "${WIN_ARRAY[3]}" "$RT_L"
                tile_win "${WIN_ARRAY[4]}" "$RT_R"
                next_cycle=1
                ;;
            *)
                tile_win "${WIN_ARRAY[0]}" "$LT"
                tile_win "${WIN_ARRAY[1]}" "$LB"
                tile_win "${WIN_ARRAY[2]}" "$RT"
                tile_win "${WIN_ARRAY[3]}" "$RB_L"
                tile_win "${WIN_ARRAY[4]}" "$RB_R"
                next_cycle=2
                ;;
        esac
        echo "$next_cycle" > "$CYCLE_FILE"
        ;;
    6)
        case $cur_cy in
            1)
                tile_win "${WIN_ARRAY[0]}" "$LT"
                tile_win "${WIN_ARRAY[1]}" "$LB"
                tile_win "${WIN_ARRAY[2]}" "$RT_L"
                tile_win "${WIN_ARRAY[3]}" "$RT_R"
                tile_win "${WIN_ARRAY[4]}" "$RB_L"
                tile_win "${WIN_ARRAY[5]}" "$RB_R"
                next_cycle=2
                ;;
            2)
                tile_win "${WIN_ARRAY[0]}" "$RT"
                tile_win "${WIN_ARRAY[1]}" "$RB"
                tile_win "${WIN_ARRAY[2]}" "$LT_L"
                tile_win "${WIN_ARRAY[3]}" "$LT_R"
                tile_win "${WIN_ARRAY[4]}" "$LB_L"
                tile_win "${WIN_ARRAY[5]}" "$LB_R"
                next_cycle=3
                ;;
            3)
                tile_win "${WIN_ARRAY[0]}" "$LB"
                tile_win "${WIN_ARRAY[1]}" "$RB"
                tile_win "${WIN_ARRAY[2]}" "$LT_L"
                tile_win "${WIN_ARRAY[3]}" "$LT_R"
                tile_win "${WIN_ARRAY[4]}" "$RT_L"
                tile_win "${WIN_ARRAY[5]}" "$RT_R"
                next_cycle=4
                ;;
            4)
                tile_win "${WIN_ARRAY[0]}" "$LT"
                tile_win "${WIN_ARRAY[1]}" "$RT"
                tile_win "${WIN_ARRAY[2]}" "$LB_L"
                tile_win "${WIN_ARRAY[3]}" "$LB_R"
                tile_win "${WIN_ARRAY[4]}" "$RB_L"
                tile_win "${WIN_ARRAY[5]}" "$RB_R"
                next_cycle=1
                ;;
            *)
                tile_win "${WIN_ARRAY[0]}" "$LT"
                tile_win "${WIN_ARRAY[1]}" "$LB"
                tile_win "${WIN_ARRAY[2]}" "$RT_L"
                tile_win "${WIN_ARRAY[3]}" "$RT_R"
                tile_win "${WIN_ARRAY[4]}" "$RB_L"
                tile_win "${WIN_ARRAY[5]}" "$RB_R"
                next_cycle=2
                ;;
        esac
        echo "$next_cycle" > "$CYCLE_FILE"
        ;;
    7)
        case $cur_cy in
            1)
                tile_win "${WIN_ARRAY[0]}" "$LT"
                tile_win "${WIN_ARRAY[1]}" "$LB_L"
                tile_win "${WIN_ARRAY[2]}" "$LB_R"
                tile_win "${WIN_ARRAY[3]}" "$RT_L"
                tile_win "${WIN_ARRAY[4]}" "$RT_R"
                tile_win "${WIN_ARRAY[5]}" "$RB_L"
                tile_win "${WIN_ARRAY[6]}" "$RB_R"
                next_cycle=2
                ;;
            2)
                tile_win "${WIN_ARRAY[0]}" "$LB"
                tile_win "${WIN_ARRAY[1]}" "$LT_L"
                tile_win "${WIN_ARRAY[2]}" "$LT_R"
                tile_win "${WIN_ARRAY[3]}" "$RT_L"
                tile_win "${WIN_ARRAY[4]}" "$RT_R"
                tile_win "${WIN_ARRAY[5]}" "$RB_L"
                tile_win "${WIN_ARRAY[6]}" "$RB_R"
                next_cycle=3
                ;;
            3)
                tile_win "${WIN_ARRAY[0]}" "$RT"
                tile_win "${WIN_ARRAY[1]}" "$LT_L"
                tile_win "${WIN_ARRAY[2]}" "$LT_R"
                tile_win "${WIN_ARRAY[3]}" "$LB_L"
                tile_win "${WIN_ARRAY[4]}" "$LB_R"
                tile_win "${WIN_ARRAY[5]}" "$RB_L"
                tile_win "${WIN_ARRAY[6]}" "$RB_R"
                next_cycle=4
                ;;
            4)
                tile_win "${WIN_ARRAY[0]}" "$RB"
                tile_win "${WIN_ARRAY[1]}" "$LT_L"
                tile_win "${WIN_ARRAY[2]}" "$LT_R"
                tile_win "${WIN_ARRAY[3]}" "$LB_L"
                tile_win "${WIN_ARRAY[4]}" "$LB_R"
                tile_win "${WIN_ARRAY[5]}" "$RT_L"
                tile_win "${WIN_ARRAY[6]}" "$RT_R"
                next_cycle=1
                ;;
            *)
                tile_win "${WIN_ARRAY[0]}" "$LT"
                tile_win "${WIN_ARRAY[1]}" "$LB_L"
                tile_win "${WIN_ARRAY[2]}" "$LB_R"
                tile_win "${WIN_ARRAY[3]}" "$RT_L"
                tile_win "${WIN_ARRAY[4]}" "$RT_R"
                tile_win "${WIN_ARRAY[5]}" "$RB_L"
                tile_win "${WIN_ARRAY[6]}" "$RB_R"
                next_cycle=2
                ;;
        esac
        echo "$next_cycle" > "$CYCLE_FILE"
        ;;
    8)
        case $cur_cy in
            1)
                tile_win "${WIN_ARRAY[0]}" "$LT_L"
                tile_win "${WIN_ARRAY[1]}" "$LT_R"
                tile_win "${WIN_ARRAY[2]}" "$LB_L"
                tile_win "${WIN_ARRAY[3]}" "$LB_R"
                tile_win "${WIN_ARRAY[4]}" "$RT_L"
                tile_win "${WIN_ARRAY[5]}" "$RT_R"
                tile_win "${WIN_ARRAY[6]}" "$RB_L"
                tile_win "${WIN_ARRAY[7]}" "$RB_R"
                next_cycle=1
                ;;
            *)
                tile_win "${WIN_ARRAY[0]}" "$LT_L"
                tile_win "${WIN_ARRAY[1]}" "$LT_R"
                tile_win "${WIN_ARRAY[2]}" "$LB_L"
                tile_win "${WIN_ARRAY[3]}" "$LB_R"
                tile_win "${WIN_ARRAY[4]}" "$RT_L"
                tile_win "${WIN_ARRAY[5]}" "$RT_R"
                tile_win "${WIN_ARRAY[6]}" "$RB_L"
                tile_win "${WIN_ARRAY[7]}" "$RB_R"
                next_cycle=1
                ;;
        esac
        echo "$next_cycle" > "$CYCLE_FILE"
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
