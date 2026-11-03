#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    notify-send "detect-tile.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

TILE_W=396
TILE_H=400
TOLERANCE=25

wid=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --wid)
            wid="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

if [ -z "$wid" ]; then
    wid=$(xdotool getactivewindow 2>/dev/null)
fi

if [ -z "$wid" ] || [ "$wid" == "0" ] || [ "$wid" == "0x0" ]; then
    echo "UNKNOWN"
    exit 0
fi

wid_hex=$(awk -v id="$wid" 'BEGIN {printf "0x%08x\n", id}')

cur_geom=$(wmctrl -l -G | awk -v id="$wid_hex" '$1 == id {print $3,$4,$5,$6}')

if [ -z "$cur_geom" ]; then
    cur_geom=$(wmctrl -l -G | awk -v id="$wid" '$1 == id {print $3,$4,$5,$6}')
fi

if [ -z "$cur_geom" ]; then
    eval $(xdotool getwindowgeometry --shell "$wid" 2>/dev/null)
    cur_geom="$X $Y $WIDTH $HEIGHT"
fi

read -r win_x win_y win_w win_h <<< "$cur_geom"

read -r screen_w screen_h <<< $(xdotool getdisplaygeometry)

matched_tile="UNKNOWN"

abs_diff_matches() {
    local val1=$1
    local val2=$2
    local diff=$((val1 - val2))
    [ $diff -lt 0 ] && diff=$((-diff))
    [ $diff -le $TOLERANCE ]
}

if abs_diff_matches $win_w $TILE_W && abs_diff_matches $win_h $TILE_H; then
    
    if abs_diff_matches $win_y 0 || [ $win_y -le $((TOLERANCE + 45)) ]; then
        if abs_diff_matches $win_x 0; then
            matched_tile="LT_L"
        elif abs_diff_matches $win_x $TILE_W; then
            matched_tile="LT_R"
        elif abs_diff_matches $win_x $((TILE_W * 2)); then
            matched_tile="RT_L"
        elif abs_diff_matches $win_x $((screen_w - TILE_W)); then
            matched_tile="RT_R"
        fi

    elif abs_diff_matches $win_y $TILE_H || [ $((screen_h - (win_y + win_h))) -le $((TOLERANCE + 45)) ]; then
        if abs_diff_matches $win_x 0; then
            matched_tile="LB_L"
        elif abs_diff_matches $win_x $TILE_W; then
            matched_tile="LB_R"
        elif abs_diff_matches $win_x $((TILE_W * 2)); then
            matched_tile="RB_L"
        elif abs_diff_matches $win_x $((screen_w - TILE_W)); then
            matched_tile="RB_R"
        fi
    fi

elif abs_diff_matches $win_w $((TILE_W * 2)) && abs_diff_matches $win_h $TILE_H; then

    if abs_diff_matches $win_y 0 || [ $win_y -le $((TOLERANCE + 45)) ]; then
        if abs_diff_matches $win_x 0; then
            matched_tile="LT"
        elif abs_diff_matches $win_x $((TILE_W * 2)) || abs_diff_matches $win_x $((screen_w - (TILE_W * 2))); then
            matched_tile="RT"
        fi

    elif abs_diff_matches $win_y $TILE_H || [ $((screen_h - (win_y + win_h))) -le $((TOLERANCE + 45)) ]; then
        if abs_diff_matches $win_x 0; then
            matched_tile="LB"
        elif abs_diff_matches $win_x $((TILE_W * 2)) || abs_diff_matches $win_x $((screen_w - (TILE_W * 2))); then
            matched_tile="RB"
        fi
    fi

else
    half_screen_w=$((screen_w / 2))
    
    is_left_edge=0;   [ $win_x -le $TOLERANCE ] && is_left_edge=1
    is_right_edge=0;  [ $((screen_w - (win_x + win_w))) -le $TOLERANCE ] && is_right_edge=1
    is_top_edge=0;    [ $win_y -le $((TOLERANCE + 45)) ] && is_top_edge=1
    is_bottom_edge=0; [ $((screen_h - (win_y + win_h))) -le $((TOLERANCE + 45)) ] && is_bottom_edge=1

    if [ $is_top_edge -eq 1 ] && [ $is_bottom_edge -eq 1 ]; then
        if [ $is_left_edge -eq 1 ] && [ $is_right_edge -eq 1 ]; then
            matched_tile="M"
        elif [ $is_left_edge -eq 1 ] && abs_diff_matches $win_w $half_screen_w; then
            matched_tile="L"
        elif [ $is_right_edge -eq 1 ] && abs_diff_matches $win_w $half_screen_w; then
            matched_tile="R"
        elif abs_diff_matches $win_w $TILE_W; then
            matched_tile="CG"
        fi
    elif [ $is_left_edge -eq 1 ] && [ $is_right_edge -eq 1 ]; then
        if [ $is_top_edge -eq 1 ]; then
            matched_tile="T"
        elif [ $is_bottom_edge -eq 1 ]; then
            matched_tile="B"
        fi
    fi
fi

if [ "$matched_tile" == "UNKNOWN" ]; then
    if [ $win_w -ge $((screen_w - 50)) ] && [ $win_h -ge $((screen_h - 100)) ]; then
        matched_tile="M"
    fi
fi

echo "$matched_tile"
