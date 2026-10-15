#!/bin/bash

# "$HOME/willyhorizont.github.io/.config/tile.conf"
# LT           = 2    60  798  401 
# LT_L         = 2    60  398  401
# LT_R         = 404  60  398  401
# LB           = 2    484 798  401 
# LB_L         = 2    484 398  401
# LB_R         = 404  484 398  401
# RT           = 802  60  798  401 
# RT_L         = 804  60  398  401
# RT_R         = 1202 60  398  401
# RB           = 802  484 798  401 
# RB_L         = 804  484 398  401
# RB_R         = 1202 484 398  401
# L            = 2    60  798  825
# R            = 802  60  798  825
# CG           = 48   54  1504 771

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    notify-send "tile-cur-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

CONF_FILE="$HOME/willyhorizont.github.io/.config/tile.conf"

if [ ! -f "$CONF_FILE" ]; then
    notify-send "tile-cur-wrkspc.sh" "Error: $CONF_FILE not found!"
    exit 1
fi

get_geom() {
    local k=$1
    echo $(grep "^${k}[[:space:]]*=" "$CONF_FILE" | sed 's/=//g' | awk '{$1=""; print $0}')
}

get_conf_v() {
    local k=$1
    grep "^${k}[[:space:]]*=" "$CONF_FILE" | cut -d'=' -f2 | tr -d '[:space:]'
}

x_offset=$(get_conf_v "x_offset")
y_offset=$(get_conf_v "y_offset")
x_offset=${x_offset:-0}
y_offset=${y_offset:-0}

tile_win_ver_a() {
    local wid=$1
    local k=$2
    local geom=$(get_geom "$k")
    local c_ls=($geom)
    local x=${c_ls[0]}
    local y=${c_ls[1]}
    local w=${c_ls[2]}
    local h=${c_ls[3]}
    if [ -z "$x" ] || [ -z "$y" ] || [ -z "$w" ] || [ -z "$h" ]; then
        notify-send "tile-cur-wrkspc.sh" "Error: Invalid geometry for $k in $CONF_FILE"
        return 1
    fi
    wmctrl -i -r "$wid" -b remove,maximized_vert,maximized_horz
    xdotool windowsize "$wid" "$w" "$h"
    xdotool windowmove "$wid" "$x" "$y"
}

tile_win_ver_b() {
    local wid=$1
    local k=$2
    local geom=$(get_geom "$k")
    local c_ls=($geom)
    local x_conf=${c_ls[0]}
    local y_conf=${c_ls[1]}
    local w=${c_ls[2]}
    local h=${c_ls[3]}
    if [ -z "$x_conf" ] || [ -z "$y_conf" ] || [ -z "$w" ] || [ -z "$h" ]; then
        notify-send "tile-cur-wrkspc.sh" "Error: Invalid geometry for $k in $CONF_FILE"
        return 1
    fi
    local x=$(( x_conf - x_offset ))
    local y=$(( y_conf - y_offset ))
    if [ $x -lt 0 ]; then x=0; fi
    if [ $y -lt 0 ]; then y=0; fi
    wmctrl -i -r "$wid" -b remove,maximized_vert,maximized_horz
    xdotool windowsize "$wid" "$w" "$h"
    xdotool windowmove "$wid" "$x" "$y"
}

tile_win_ver_c() {
    local wid=$1
    local k=$2
    local geom=$(get_geom "$k")
    local c_ls=($geom)
    local x_conf=${c_ls[0]}
    local y_conf=${c_ls[1]}
    local w=${c_ls[2]}
    local h=${c_ls[3]}
    if [ -z "$x_conf" ] || [ -z "$y_conf" ] || [ -z "$w" ] || [ -z "$h" ]; then
        notify-send "tile-cur-wrkspc.sh" "Error: Invalid geometry for $k in $CONF_FILE"
        return 1
    fi
    wmctrl -i -r "$wid" -b remove,maximized_vert,maximized_horz
    xdotool windowsize "$wid" "$w" "$h"
    xdotool windowmove "$wid" "$x_conf" "$y_conf"
    local real_geom=$(wmctrl -l -x -G | awk -v id="$wid" '$1 == id')
    local real_x=$(echo "$real_geom" | awk '{print $3}')
    local real_y=$(echo "$real_geom" | awk '{print $4}')
    local x_offset=$(( real_x - x_conf ))
    local y_offset=$(( real_y - y_conf ))
    local x=$(( x_conf - x_offset ))
    local y=$(( y_conf - y_offset ))
    if [ $x -lt 0 ]; then x=0; fi
    if [ $y -lt 0 ]; then y=0; fi
    wmctrl -i -r "$wid" -b remove,maximized_vert,maximized_horz
    xdotool windowsize "$wid" "$w" "$h"
    xdotool windowmove "$wid" "$x" "$y"
}

tile_win() {
    tile_win_ver_c "$@"
}

cur_wrkspc=$(wmctrl -d | grep '*' | awk '{print $1}')
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

case $WIN_COUNT in
    1)
        tile_win "${WIN_ARRAY[0]}" "CG"
        ;;
    2)
        tile_win "${WIN_ARRAY[0]}" "L"
        tile_win "${WIN_ARRAY[1]}" "R"
        ;;
    3)
        tile_win "${WIN_ARRAY[0]}" "L"
        tile_win "${WIN_ARRAY[1]}" "RT"
        tile_win "${WIN_ARRAY[2]}" "RB"
        ;;
    4)
        tile_win "${WIN_ARRAY[0]}" "LT"
        tile_win "${WIN_ARRAY[1]}" "LB"
        tile_win "${WIN_ARRAY[2]}" "RT"
        tile_win "${WIN_ARRAY[3]}" "RB"
        ;;
    5)
        tile_win "${WIN_ARRAY[0]}" "LT"
        tile_win "${WIN_ARRAY[1]}" "LB"
        tile_win "${WIN_ARRAY[2]}" "RT"
        tile_win "${WIN_ARRAY[3]}" "RB_L"
        tile_win "${WIN_ARRAY[4]}" "RB_R"
        ;;
    6)
        tile_win "${WIN_ARRAY[0]}" "LT"
        tile_win "${WIN_ARRAY[1]}" "LB"
        tile_win "${WIN_ARRAY[2]}" "RT_L"
        tile_win "${WIN_ARRAY[3]}" "RT_R"
        tile_win "${WIN_ARRAY[4]}" "RB_L"
        tile_win "${WIN_ARRAY[5]}" "RB_R"
        ;;
    7)
        tile_win "${WIN_ARRAY[0]}" "LT"
        tile_win "${WIN_ARRAY[1]}" "LB_L"
        tile_win "${WIN_ARRAY[2]}" "LB_R"
        tile_win "${WIN_ARRAY[3]}" "RT_L"
        tile_win "${WIN_ARRAY[4]}" "RT_R"
        tile_win "${WIN_ARRAY[5]}" "RB_L"
        tile_win "${WIN_ARRAY[6]}" "RB_R"
        ;;
    8)
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
        tile_win "${WIN_ARRAY[0]}" "LT"
        tile_win "${WIN_ARRAY[1]}" "LB"
        tile_win "${WIN_ARRAY[2]}" "RT"
        tile_win "${WIN_ARRAY[3]}" "RB_L"
        for ((i=4; i<WIN_COUNT; i++)); do
            tile_win "${WIN_ARRAY[i]}" "RB_R"
        done
        ;;
esac
