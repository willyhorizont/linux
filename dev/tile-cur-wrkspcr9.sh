#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    notify-send "tile-cur-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

CFG="$HOME/willyhorizont.github.io/.config/tile.conf"
if [ ! -f "$CFG" ]; then
    notify-send "tile-cur-wrkspc.sh" "Error: tile.conf no found!"
    exit 1
fi

apply_corners_layout() {
    local win_id="$1"
    local label="$2"

    local geom_str
    geom_str=$(grep "^$label" "$CFG" | cut -d';' -f2 | sed 's/^[[:space:]]*//')

    if [ -z "$geom_str" ]; then
        return 1
    fi

    local bl; local br; local tr; local tl
    bl=$(echo "$geom_str" | awk '{print $1}')
    br=$(echo "$geom_str" | awk '{print $2}')
    tr=$(echo "$geom_str" | awk '{print $3}')
    tl=$(echo "$geom_str" | awk '{print $4}')

    local target_x
    local target_y
    target_x=$(echo "$tl" | grep -oE '^[+-][0-9]+')
    target_y=$(echo "$tl" | grep -oE '[+-][0-9]+$')

    local screen_h
    screen_h=$(xdotool getdisplaygeometry | awk '{print $2}')
    local screen_w
    screen_w=$(xdotool getdisplaygeometry | awk '{print $1}')

    if echo "$target_y" | grep -q '^-'; then
        local abs_y_val=${target_y#-}
        target_y=$((screen_h - abs_y_val))
    else
        target_y=${target_y#+}
    fi

    if echo "$target_x" | grep -q '^-'; then
        local abs_x_val=${target_x#-}
        target_x=$((screen_w - abs_x_val))
    else
        target_x=${target_x#+}
    fi

    local bl_x; local br_x
    bl_x=$(echo "$bl" | grep -oE '^[+-][0-9]+')
    br_x=$(echo "$br" | grep -oE '^[+-][0-9]+')

    [[ "$bl_x" =~ ^- ]] && bl_x=$((screen_w + bl_x)) || bl_x=${bl_x#+}
    [[ "$br_x" =~ ^- ]] && br_x=$((screen_w + br_x)) || br_x=${br_x#+}
    local target_w=$((br_x - bl_x))
    [ "$target_w" -lt 0 ] && target_w=$((target_w * -1))

    local bl_y; local tl_y
    bl_y=$(echo "$bl" | grep -oE '[+-][0-9]+$')
    tl_y=$(echo "$tl" | grep -oE '[+-][0-9]+$')

    [[ "$bl_y" =~ ^- ]] && bl_y=$((screen_h + bl_y)) || bl_y=${bl_y#+}
    [[ "$tl_y" =~ ^- ]] && tl_y=$((screen_h + tl_y)) || tl_y=${tl_y#+}
    local target_h=$((bl_y - tl_y))
    [ "$target_h" -lt 0 ] && target_h=$((target_h * -1))

    xdotool windowsize "$win_id" "$target_w" "$target_h"
    xdotool windowmove "$win_id" "$target_x" "$target_y"

    sleep 0.01
    local actual_h
    actual_h=$(xdotool getwindowgeometry "$win_id" 2>/dev/null | grep -oE 'Geometry: [0-9]+x[0-9]+' | cut -d'x' -f2)
    if [ -n "$actual_h" ] && [ "$actual_h" -gt "$target_h" ]; then
        local delta=$((actual_h - target_h))
        xdotool windowsize "$win_id" "$target_w" "$((target_h - delta))"
        xdotool windowmove "$win_id" "$target_x" "$target_y"
    fi
}

cur_wrkspc=$(wmctrl -d | grep '*' | cut -d' ' -f1)

OPEN_WINS=$(wmctrl -l -x | awk -v ws="$cur_wrkspc" '$2 == ws && !( ($3 == "pcmanfm.Pcmanfm" && $5 == "pcmanfm") || ($3 == "plank.Plank" && $5 == "plank") || ($3 == "tint2.Tint2") ||  ($4 ~ /welcome-window|idle-window/) || ($3 == "xpenguins.Xpenguins") ) {print $1}')

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
        apply_corners_layout "$W_0" "Right (Master)"
        ;;
    2)
        apply_corners_layout "$W_0" "Right (Master)"
        apply_corners_layout "$W_1" "Top Left (Stack)"
        ;;
    3)
        apply_corners_layout "$W_0" "Right (Master)"
        apply_corners_layout "$W_1" "Top Left (Stack)"
        apply_corners_layout "$W_2" "Bottom Left (Stack)"
        ;;
    4)
        apply_corners_layout "$W_0" "Right (Master)"
        apply_corners_layout "$W_1" "Top Left (Stack)"
        apply_corners_layout "$W_2" "Bottom Left - Left"
        apply_corners_layout "$W_3" "Bottom Left - Right"
        ;;
    *)
        apply_corners_layout "$W_0" "Right (Master)"
        apply_corners_layout "$W_1" "Top Left (Stack)"
        apply_corners_layout "$W_2" "Bottom Left - Left"
        apply_corners_layout "$W_3" "Bottom Left - Right"
        
        local idx=1
        for w_stacked in $OPEN_WINS; do
            if [ "$idx" -gt 4 ]; then
                apply_corners_layout "$w_stacked" "Right (Master)"
            fi
            idx=$((idx + 1))
        done
        ;;
esac
