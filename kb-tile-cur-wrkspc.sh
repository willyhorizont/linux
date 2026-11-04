#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    notify-send "kb-tile-cur-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

IS_CYCLE=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --cycle)
            IS_CYCLE=1
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# cur_wrkspc=$(wmctrl -d | awk '{if ($2 == "*") print $1}')
cur_wrkspc=$(xdotool get_desktop)
WIDS=$("$HOME/willyhorizont.github.io/linux/get-open-wins.sh" | awk -v ws="$cur_wrkspc" '$2 == ws {print $1}')

WID_ARRAY=($WIDS)
WID_COUNT=${#WID_ARRAY[@]}

if [ "$WID_COUNT" -eq 0 ]; then
    exit 0
fi

F="ctrl+super+z"           # C-W-z
M="ctrl+super+f"           # C-W-f
CG="ctrl+super+g"          # C-W-g
L="super+Left"             # W-Left
R="super+Right"            # W-Right
T="super+Up"               # W-Up
B="super+Down"             # W-Down
LT="ctrl+super+shift+u"    # C-W-S-u
LT_L="ctrl+super+shift+t"  # C-W-S-t
LT_R="ctrl+super+shift+y"  # C-W-S-y
LB="ctrl+super+shift+h"    # C-W-S-h
LB_L="ctrl+super+shift+f"  # C-W-S-f
LB_R="ctrl+super+shift+g"  # C-W-S-g
RT="ctrl+super+shift+i"    # C-W-S-i
RT_L="ctrl+super+shift+o"  # C-W-S-o
RT_R="ctrl+super+shift+p"  # C-W-S-p
RB="ctrl+super+shift+j"    # C-W-S-j
RB_L="ctrl+super+shift+k"  # C-W-S-k
RB_R="ctrl+super+shift+l"  # C-W-S-l

declare -A slot_dict
slot_dict["$F"]="F"
slot_dict["$M"]="M"
slot_dict["$CG"]="CG"
slot_dict["$L"]="L"
slot_dict["$R"]="R"
slot_dict["$T"]="T"
slot_dict["$B"]="B"
slot_dict["$LT"]="LT"
slot_dict["$LT_L"]="LT_L"
slot_dict["$LT_R"]="LT_R"
slot_dict["$LB"]="LB"
slot_dict["$LB_L"]="LB_L"
slot_dict["$LB_R"]="LB_R"
slot_dict["$RT"]="RT"
slot_dict["$RT_L"]="RT_L"
slot_dict["$RT_R"]="RT_R"
slot_dict["$RB"]="RB"
slot_dict["$RB_L"]="RB_L"
slot_dict["$RB_R"]="RB_R"

tile_win() {
    local wid=$1
    local kb=$2
    
    local expected_tile_pos=${slot_dict["$kb"]}
    local detected_tile_pos=$($HOME/willyhorizont.github.io/linux/detect-tile.sh --wid "$wid")
    if [ "$detected_tile_pos" == "$expected_tile_pos" ]; then
        return 0
    fi

    # wmctrl -i -r "$wid" -b remove,maximized_vert,maximized_horz
    xdotool windowactivate --sync "$wid"
    sleep 0.2
    # wmctrl -i -a "$wid"
    xdotool key "$kb"
    sleep 0.2

    retried_tile_pos=$($HOME/willyhorizont.github.io/linux/detect-tile.sh --wid "$wid")
    local retry_count=0
    
    while [ "$retried_tile_pos" != "$expected_tile_pos" ] && [ $retry_count -lt 5 ]; do
        xdotool windowactivate --sync "$wid"
        sleep 0.2
        xdotool key "$kb"
        sleep 0.2
        retried_tile_pos=$($HOME/willyhorizont.github.io/linux/detect-tile.sh --wid "$wid")
        retry_count=$((retry_count + 1))
    done

    # pos=""
    # [ "$kb" == "$F" ] && pos="F"
    # [ "$kb" == "$M" ] && pos="M"
    # [ "$kb" == "$CG" ] && pos="CG"
    # [ "$kb" == "$L" ] && pos="L"
    # [ "$kb" == "$R" ] && pos="R"
    # [ "$kb" == "$T" ] && pos="T"
    # [ "$kb" == "$B" ] && pos="B"
    # [ "$kb" == "$LT" ] && pos="LT"
    # [ "$kb" == "$LT_L" ] && pos="LT_L"
    # [ "$kb" == "$LT_R" ] && pos="LT_R"
    # [ "$kb" == "$LB" ] && pos="LB"
    # [ "$kb" == "$LB_L" ] && pos="LB_L"
    # [ "$kb" == "$LB_R" ] && pos="LB_R"
    # [ "$kb" == "$RT" ] && pos="RT"
    # [ "$kb" == "$RT_L" ] && pos="RT_L"
    # [ "$kb" == "$RT_R" ] && pos="RT_R"
    # [ "$kb" == "$RB" ] && pos="RB"
    # [ "$kb" == "$RB_L" ] && pos="RB_L"
    # [ "$kb" == "$RB_R" ] && pos="RB_R"
    # window_title=$(xdotool getwindowname "$wid" 2>/dev/null)
    # notify-send "WID_COUNT: $WID_COUNT" "$pos | $window_title"
}

CYCLE_FILE="/tmp/tile-cycle-ws-${cur_wrkspc}-wins-${WID_COUNT}.state"

if [ "$IS_CYCLE" -eq 1 ]; then
    cur_cy=$(cat "$CYCLE_FILE" 2>/dev/null)
    cur_cy=${cur_cy:-1}
else
    cur_cy=1
fi

case $WID_COUNT in
    1)
        case $cur_cy in
            1)
                tile_win "${WID_ARRAY[0]}" "$M"
                next_cycle=2
                ;;
            2)
                tile_win "${WID_ARRAY[0]}" "$CG"
                next_cycle=1
                ;;
            *)
                tile_win "${WID_ARRAY[0]}" "$M"
                next_cycle=2
                ;;
        esac
        [ "$IS_CYCLE" -eq 1 ] && echo "$next_cycle" > "$CYCLE_FILE"
        ;;
    2)
        case $cur_cy in
            1)
                tile_win "${WID_ARRAY[0]}" "$L"
                tile_win "${WID_ARRAY[1]}" "$R"
                next_cycle=2
                ;;
            2)
                tile_win "${WID_ARRAY[0]}" "$T"
                tile_win "${WID_ARRAY[1]}" "$B"
                next_cycle=1
                ;;
            *)
                tile_win "${WID_ARRAY[0]}" "$L"
                tile_win "${WID_ARRAY[1]}" "$R"
                next_cycle=2
                ;;
        esac
        [ "$IS_CYCLE" -eq 1 ] && echo "$next_cycle" > "$CYCLE_FILE"
        ;;
    3)
        case $cur_cy in
            1)
                tile_win "${WID_ARRAY[0]}" "$L"
                tile_win "${WID_ARRAY[1]}" "$RT"
                tile_win "${WID_ARRAY[2]}" "$RB"
                next_cycle=2
                ;;
            2)
                tile_win "${WID_ARRAY[0]}" "$R"
                tile_win "${WID_ARRAY[1]}" "$LT"
                tile_win "${WID_ARRAY[2]}" "$LB"
                next_cycle=3
                ;;
            3)
                tile_win "${WID_ARRAY[0]}" "$T"
                tile_win "${WID_ARRAY[1]}" "$LB"
                tile_win "${WID_ARRAY[2]}" "$RB"
                next_cycle=4
                ;;
            4)
                tile_win "${WID_ARRAY[0]}" "$B"
                tile_win "${WID_ARRAY[1]}" "$LT"
                tile_win "${WID_ARRAY[2]}" "$RT"
                next_cycle=1
                ;;
            *)
                tile_win "${WID_ARRAY[0]}" "$L"
                tile_win "${WID_ARRAY[1]}" "$RT"
                tile_win "${WID_ARRAY[2]}" "$RB"
                next_cycle=2
                ;;
        esac
        [ "$IS_CYCLE" -eq 1 ] && echo "$next_cycle" > "$CYCLE_FILE"
        ;;
    4)
        case $cur_cy in
            1)
                tile_win "${WID_ARRAY[0]}" "$LT"
                tile_win "${WID_ARRAY[1]}" "$LB"
                tile_win "${WID_ARRAY[2]}" "$RT"
                tile_win "${WID_ARRAY[3]}" "$RB"
                next_cycle=2
                ;;
            2)
                tile_win "${WID_ARRAY[0]}" "$L"
                tile_win "${WID_ARRAY[1]}" "$RT"
                tile_win "${WID_ARRAY[2]}" "$RB_L"
                tile_win "${WID_ARRAY[3]}" "$RB_R"
                next_cycle=3
                ;;
            3)
                tile_win "${WID_ARRAY[0]}" "$L"
                tile_win "${WID_ARRAY[1]}" "$RB"
                tile_win "${WID_ARRAY[2]}" "$RT_L"
                tile_win "${WID_ARRAY[3]}" "$RT_R"
                next_cycle=4
                ;;
            4)
                tile_win "${WID_ARRAY[0]}" "$R"
                tile_win "${WID_ARRAY[1]}" "$LT"
                tile_win "${WID_ARRAY[2]}" "$LB_L"
                tile_win "${WID_ARRAY[3]}" "$LB_R"
                next_cycle=5
                ;;
            5)
                tile_win "${WID_ARRAY[0]}" "$R"
                tile_win "${WID_ARRAY[1]}" "$LB"
                tile_win "${WID_ARRAY[2]}" "$LT_L"
                tile_win "${WID_ARRAY[3]}" "$LT_R"
                next_cycle=6
                ;;
            6)
                tile_win "${WID_ARRAY[0]}" "$T"
                tile_win "${WID_ARRAY[1]}" "$LB"
                tile_win "${WID_ARRAY[2]}" "$RB_L"
                tile_win "${WID_ARRAY[3]}" "$RB_R"
                next_cycle=7
                ;;
            7)
                tile_win "${WID_ARRAY[0]}" "$T"
                tile_win "${WID_ARRAY[1]}" "$RB"
                tile_win "${WID_ARRAY[2]}" "$LB_L"
                tile_win "${WID_ARRAY[3]}" "$LB_R"
                next_cycle=8
                ;;
            8)
                tile_win "${WID_ARRAY[0]}" "$B"
                tile_win "${WID_ARRAY[1]}" "$LT"
                tile_win "${WID_ARRAY[2]}" "$RT_L"
                tile_win "${WID_ARRAY[3]}" "$RT_R"
                next_cycle=9
                ;;
            9)
                tile_win "${WID_ARRAY[0]}" "$B"
                tile_win "${WID_ARRAY[1]}" "$RT"
                tile_win "${WID_ARRAY[2]}" "$LT_L"
                tile_win "${WID_ARRAY[3]}" "$LT_R"
                next_cycle=1
                ;;
            *)
                tile_win "${WID_ARRAY[0]}" "$LT"
                tile_win "${WID_ARRAY[1]}" "$LB"
                tile_win "${WID_ARRAY[2]}" "$RT"
                tile_win "${WID_ARRAY[3]}" "$RB"
                next_cycle=2
                ;;
        esac
        [ "$IS_CYCLE" -eq 1 ] && echo "$next_cycle" > "$CYCLE_FILE"
        ;;
    5)
        case $cur_cy in
            1)
                tile_win "${WID_ARRAY[0]}" "$LT"
                tile_win "${WID_ARRAY[1]}" "$LB"
                tile_win "${WID_ARRAY[2]}" "$RT"
                tile_win "${WID_ARRAY[3]}" "$RB_L"
                tile_win "${WID_ARRAY[4]}" "$RB_R"
                next_cycle=2
                ;;
            2)
                tile_win "${WID_ARRAY[0]}" "$LT"
                tile_win "${WID_ARRAY[1]}" "$LB_L"
                tile_win "${WID_ARRAY[2]}" "$LB_R"
                tile_win "${WID_ARRAY[3]}" "$RT"
                tile_win "${WID_ARRAY[4]}" "$RB"
                next_cycle=3
                ;;
            3)
                tile_win "${WID_ARRAY[0]}" "$LT"
                tile_win "${WID_ARRAY[1]}" "$LB"
                tile_win "${WID_ARRAY[2]}" "$RT_L"
                tile_win "${WID_ARRAY[3]}" "$RT_R"
                tile_win "${WID_ARRAY[4]}" "$RB"
                next_cycle=4
                ;;
            4)
                tile_win "${WID_ARRAY[0]}" "$LT_L"
                tile_win "${WID_ARRAY[1]}" "$LT_R"
                tile_win "${WID_ARRAY[2]}" "$LB"
                tile_win "${WID_ARRAY[3]}" "$RT"
                tile_win "${WID_ARRAY[4]}" "$RB"
                next_cycle=5
                ;;
            5)
                tile_win "${WID_ARRAY[0]}" "$L"
                tile_win "${WID_ARRAY[1]}" "$RT_L"
                tile_win "${WID_ARRAY[2]}" "$RT_R"
                tile_win "${WID_ARRAY[3]}" "$RB_L"
                tile_win "${WID_ARRAY[4]}" "$RB_R"
                next_cycle=6
                ;;
            6)
                tile_win "${WID_ARRAY[0]}" "$R"
                tile_win "${WID_ARRAY[1]}" "$LT_L"
                tile_win "${WID_ARRAY[2]}" "$LT_R"
                tile_win "${WID_ARRAY[3]}" "$LB_L"
                tile_win "${WID_ARRAY[4]}" "$LB_R"
                next_cycle=7
                ;;
            7)
                tile_win "${WID_ARRAY[0]}" "$T"
                tile_win "${WID_ARRAY[1]}" "$LB_L"
                tile_win "${WID_ARRAY[2]}" "$LB_R"
                tile_win "${WID_ARRAY[3]}" "$RB_L"
                tile_win "${WID_ARRAY[4]}" "$RB_R"
                next_cycle=8
                ;;
            8)
                tile_win "${WID_ARRAY[0]}" "$B"
                tile_win "${WID_ARRAY[1]}" "$LT_L"
                tile_win "${WID_ARRAY[2]}" "$LT_R"
                tile_win "${WID_ARRAY[3]}" "$RT_L"
                tile_win "${WID_ARRAY[4]}" "$RT_R"
                next_cycle=1
                ;;
            *)
                tile_win "${WID_ARRAY[0]}" "$LT"
                tile_win "${WID_ARRAY[1]}" "$LB"
                tile_win "${WID_ARRAY[2]}" "$RT"
                tile_win "${WID_ARRAY[3]}" "$RB_L"
                tile_win "${WID_ARRAY[4]}" "$RB_R"
                next_cycle=2
                ;;
        esac
        [ "$IS_CYCLE" -eq 1 ] && echo "$next_cycle" > "$CYCLE_FILE"
        ;;
    6)
        case $cur_cy in
            1)
                tile_win "${WID_ARRAY[0]}" "$LT"
                tile_win "${WID_ARRAY[1]}" "$LB"
                tile_win "${WID_ARRAY[2]}" "$RT_L"
                tile_win "${WID_ARRAY[3]}" "$RT_R"
                tile_win "${WID_ARRAY[4]}" "$RB_L"
                tile_win "${WID_ARRAY[5]}" "$RB_R"
                next_cycle=2
                ;;
            2)
                tile_win "${WID_ARRAY[0]}" "$RT"
                tile_win "${WID_ARRAY[1]}" "$RB"
                tile_win "${WID_ARRAY[2]}" "$LT_L"
                tile_win "${WID_ARRAY[3]}" "$LT_R"
                tile_win "${WID_ARRAY[4]}" "$LB_L"
                tile_win "${WID_ARRAY[5]}" "$LB_R"
                next_cycle=3
                ;;
            3)
                tile_win "${WID_ARRAY[0]}" "$LB"
                tile_win "${WID_ARRAY[1]}" "$RB"
                tile_win "${WID_ARRAY[2]}" "$LT_L"
                tile_win "${WID_ARRAY[3]}" "$LT_R"
                tile_win "${WID_ARRAY[4]}" "$RT_L"
                tile_win "${WID_ARRAY[5]}" "$RT_R"
                next_cycle=4
                ;;
            4)
                tile_win "${WID_ARRAY[0]}" "$LT"
                tile_win "${WID_ARRAY[1]}" "$RT"
                tile_win "${WID_ARRAY[2]}" "$LB_L"
                tile_win "${WID_ARRAY[3]}" "$LB_R"
                tile_win "${WID_ARRAY[4]}" "$RB_L"
                tile_win "${WID_ARRAY[5]}" "$RB_R"
                next_cycle=1
                ;;
            *)
                tile_win "${WID_ARRAY[0]}" "$LT"
                tile_win "${WID_ARRAY[1]}" "$LB"
                tile_win "${WID_ARRAY[2]}" "$RT_L"
                tile_win "${WID_ARRAY[3]}" "$RT_R"
                tile_win "${WID_ARRAY[4]}" "$RB_L"
                tile_win "${WID_ARRAY[5]}" "$RB_R"
                next_cycle=2
                ;;
        esac
        [ "$IS_CYCLE" -eq 1 ] && echo "$next_cycle" > "$CYCLE_FILE"
        ;;
    7)
        case $cur_cy in
            1)
                tile_win "${WID_ARRAY[0]}" "$LT"
                tile_win "${WID_ARRAY[1]}" "$LB_L"
                tile_win "${WID_ARRAY[2]}" "$LB_R"
                tile_win "${WID_ARRAY[3]}" "$RT_L"
                tile_win "${WID_ARRAY[4]}" "$RT_R"
                tile_win "${WID_ARRAY[5]}" "$RB_L"
                tile_win "${WID_ARRAY[6]}" "$RB_R"
                next_cycle=2
                ;;
            2)
                tile_win "${WID_ARRAY[0]}" "$LB"
                tile_win "${WID_ARRAY[1]}" "$LT_L"
                tile_win "${WID_ARRAY[2]}" "$LT_R"
                tile_win "${WID_ARRAY[3]}" "$RT_L"
                tile_win "${WID_ARRAY[4]}" "$RT_R"
                tile_win "${WID_ARRAY[5]}" "$RB_L"
                tile_win "${WID_ARRAY[6]}" "$RB_R"
                next_cycle=3
                ;;
            3)
                tile_win "${WID_ARRAY[0]}" "$RT"
                tile_win "${WID_ARRAY[1]}" "$LT_L"
                tile_win "${WID_ARRAY[2]}" "$LT_R"
                tile_win "${WID_ARRAY[3]}" "$LB_L"
                tile_win "${WID_ARRAY[4]}" "$LB_R"
                tile_win "${WID_ARRAY[5]}" "$RB_L"
                tile_win "${WID_ARRAY[6]}" "$RB_R"
                next_cycle=4
                ;;
            4)
                tile_win "${WID_ARRAY[0]}" "$RB"
                tile_win "${WID_ARRAY[1]}" "$LT_L"
                tile_win "${WID_ARRAY[2]}" "$LT_R"
                tile_win "${WID_ARRAY[3]}" "$LB_L"
                tile_win "${WID_ARRAY[4]}" "$LB_R"
                tile_win "${WID_ARRAY[5]}" "$RT_L"
                tile_win "${WID_ARRAY[6]}" "$RT_R"
                next_cycle=1
                ;;
            *)
                tile_win "${WID_ARRAY[0]}" "$LT"
                tile_win "${WID_ARRAY[1]}" "$LB_L"
                tile_win "${WID_ARRAY[2]}" "$LB_R"
                tile_win "${WID_ARRAY[3]}" "$RT_L"
                tile_win "${WID_ARRAY[4]}" "$RT_R"
                tile_win "${WID_ARRAY[5]}" "$RB_L"
                tile_win "${WID_ARRAY[6]}" "$RB_R"
                next_cycle=2
                ;;
        esac
        [ "$IS_CYCLE" -eq 1 ] && echo "$next_cycle" > "$CYCLE_FILE"
        ;;
    8)
        case $cur_cy in
            1)
                tile_win "${WID_ARRAY[0]}" "$LT_L"
                tile_win "${WID_ARRAY[1]}" "$LT_R"
                tile_win "${WID_ARRAY[2]}" "$LB_L"
                tile_win "${WID_ARRAY[3]}" "$LB_R"
                tile_win "${WID_ARRAY[4]}" "$RT_L"
                tile_win "${WID_ARRAY[5]}" "$RT_R"
                tile_win "${WID_ARRAY[6]}" "$RB_L"
                tile_win "${WID_ARRAY[7]}" "$RB_R"
                next_cycle=1
                ;;
            *)
                tile_win "${WID_ARRAY[0]}" "$LT_L"
                tile_win "${WID_ARRAY[1]}" "$LT_R"
                tile_win "${WID_ARRAY[2]}" "$LB_L"
                tile_win "${WID_ARRAY[3]}" "$LB_R"
                tile_win "${WID_ARRAY[4]}" "$RT_L"
                tile_win "${WID_ARRAY[5]}" "$RT_R"
                tile_win "${WID_ARRAY[6]}" "$RB_L"
                tile_win "${WID_ARRAY[7]}" "$RB_R"
                next_cycle=1
                ;;
        esac
        [ "$IS_CYCLE" -eq 1 ] && echo "$next_cycle" > "$CYCLE_FILE"
        ;;
    *)
        tile_win "${WID_ARRAY[0]}" "$LT"
        tile_win "${WID_ARRAY[1]}" "$LB"
        tile_win "${WID_ARRAY[2]}" "$RB_R"
        tile_win "${WID_ARRAY[3]}" "$RB_L"
        for ((i=4; i<WID_COUNT; i++)); do
            tile_win "${WID_ARRAY[i]}" "$RT"
        done
        ;;
esac
