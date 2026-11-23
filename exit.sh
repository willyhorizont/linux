#!/bin/sh

SCRIPT_NAME="exit.sh"

if ! command -v xdotool >/dev/null 2>&1; then
    notify-send "$SCRIPT_NAME" "Error: missing dependencies 'xdotool'..."
    exit 1
fi

cmd_close_win=""
cmd_prev_ws=""
cmd_powr_mnu=""

while [ $# -gt 0 ]; do
    case "$1" in
        --cmd-close-win)
            [ -z "$2" ] && notify-send "[$SCRIPT_NAME]" "Error: invalid arguments!" && exit 1
            cmd_close_win="$2"
            shift 2
            ;;
        --cmd-prev-ws)
            [ -z "$2" ] && notify-send "[$SCRIPT_NAME]" "Error: invalid arguments!" && exit 1
            cmd_prev_ws="$2"
            shift 2
            ;;
        --cmd-powr-mnu)
            [ -z "$2" ] && notify-send "[$SCRIPT_NAME]" "Error: invalid arguments!" && exit 1
            cmd_powr_mnu="$2"
            shift 2
            ;;
        *)
            echo "Usage: $0 --cmd-close-win <cmd> --cmd-prev-ws <cmd> --cmd-powr-mnu <cmd>"
            exit 1
            ;;
    esac
done

if [ -z "$cmd_close_win" ] || [ -z "$cmd_prev_ws" ] || [ -z "$cmd_powr_mnu" ]; then
    notify-send "[$SCRIPT_NAME]" "Error: invalid arguments!"
    exit 1
fi

OPEN_WINS_DATA=$("$HOME/willyhorizont.github.io/linux/get-open-wins.sh")
TOT_WRKSPC=$(xdotool get_num_desktops 2>/dev/null)
TOT_WRKSPC=${TOT_WRKSPC:-1}
CUR_WRKSPC=$(xdotool get_desktop 2>/dev/null)
CUR_WRKSPC=${CUR_WRKSPC:-0}
CUR_WINS_COUNT=$(echo "$OPEN_WINS_DATA" | awk -v ws="$CUR_WRKSPC" 'NF && $2 == ws {count++} END {print count+0}')

if [ "$CUR_WINS_COUNT" -gt 0 ]; then
    TRGT_WIN_ID=$(xdotool getwindowfocus 2>/dev/null)
    TRGT_WIN_ID_HEX=$(printf "0x%08llx" "$TRGT_WIN_ID" 2>/dev/null || printf "0x%08x" "$TRGT_WIN_ID" 2>/dev/null)
    if [ -z "$TRGT_WIN_ID" ]; then
        CUR_WS_ANY_WIN_ID_HEX=$(echo "$OPEN_WINS_DATA" | awk -v ws="$CUR_WRKSPC" 'NF && $2 == ws {print $1; exit}')
        if [ -n "$CUR_WS_ANY_WIN_ID_HEX" ]; then
            xdotool windowactivate --sync "$CUR_WS_ANY_WIN_ID_HEX" 2>/dev/null
            TRGT_WIN_ID=$(xdotool getwindowfocus 2>/dev/null)
            TRGT_WIN_ID_HEX=$(printf "0x%08llx" "$TRGT_WIN_ID" 2>/dev/null || printf "0x%08x" "$TRGT_WIN_ID" 2>/dev/null)
        fi
    fi
    WM_CLASS=$(xprop -id "$TRGT_WIN_ID_HEX" WM_CLASS 2>/dev/null | awk -F'"' '{print $2"."$4}')
    WM_NAME=$(xdotool getwindowname "$TRGT_WIN_ID" 2>/dev/null)
    if [ "$WM_CLASS" = "." ] || [ -z "$WM_CLASS" ]; then
        WM_CLASS="N/A"
    fi
    if [ "$WM_CLASS" = "N/A" ] || [ -z "$WM_NAME" ]; then
        WIN_NM="$WM_CLASS"
    elif [ ${#WM_NAME} -gt 43 ]; then
        WIN_NM="$WM_CLASS ${WM_NAME:0:20}...${WM_NAME: -20}"
    else
        WIN_NM="$WM_CLASS $WM_NAME"
    fi
    if [ "$WIN_NM" = "N/A" ]; then
        WIN_NM="Current Window"
    else
        WIN_NM="[${WIN_NM}]"
    fi
    "$HOME/willyhorizont.github.io/linux/confirm-cmd.sh" --confirm --msg "Confirm Close ${WIN_NM}" || exit 1
    while pgrep -x rofi >/dev/null 2>&1; do
        sleep 0.2
    done
    exec sh -c "$cmd_close_win"
elif [ "$TOT_WRKSPC" -gt 1 ]; then
    exec sh -c "$cmd_prev_ws"
else
    exec sh -c "$cmd_powr_mnu"
fi
