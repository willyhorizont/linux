#!/bin/bash

SCRIPT_NAME="wrkspc-mgr.sh"

tot_wrkspc=$(xdotool get_num_desktops)
cur_wrkspc=$(xdotool get_desktop)

get_open_wins_data() {
    wmctrl -l -x -G 2>/dev/null | awk '{
        if ($7 == "pcmanfm.Pcmanfm" && $9 == "pcmanfm") next;
        if ($7 == "plank.Plank" && $9 == "plank") next;
        if ($7 == "tint2.Tint2") next;
        if ($7 == "xpenguins.Xpenguins") next;
        if ($7 ~ /welcome-window|idle-window/) next;
        print $2
    }'
}

OPEN_WINS_DATA=$(get_open_wins_data)

PROCESSED=0
MOV_WIN_MODE=false
TRGT_WIN_ID=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --goto)
            shift
            ;;
        --mov)
            MOV_WIN_MODE=true
            TRGT_WIN_ID=$(xdotool getactivewindow 2>/dev/null)
            if [ -z "$TRGT_WIN_ID" ]; then
                notify-send "$SCRIPT_NAME" "Error: Window not found!"
                exit 1
            fi
            shift
            ;;
        --plus)
            max_active_win_ws=-1
            if [ -n "$OPEN_WINS_DATA" ]; then
                max_active_win_ws=$(echo "$OPEN_WINS_DATA" | sort -nu | tail -n 1)
            fi
            if [ "$cur_wrkspc" -gt "$max_active_win_ws" ]; then
                max_valid_ws=$cur_wrkspc
            else
                max_valid_ws=$max_active_win_ws
            fi
            if [ "$max_valid_ws" -lt 0 ]; then
                max_valid_ws=0
            fi
            TRGT_WRKSPC=$(( max_valid_ws + 1 ))
            PROCESSED=1
            shift
            ;;
        --next|--prev)
            valid_workspaces=()
            for ((i=0; i<tot_wrkspc; i++)); do
                win_count=0
                if [ -n "$OPEN_WINS_DATA" ]; then
                    win_count=$(echo "$OPEN_WINS_DATA" | grep -c -w "$i")
                fi
                if [ "$win_count" -gt 0 ] || [ "$i" -eq "$cur_wrkspc" ]; then
                    valid_workspaces+=("$i")
                fi
            done
            tot_valid=${#valid_workspaces[@]}
            cur_pos=0
            for i in "${!valid_workspaces[@]}"; do
                if [ "${valid_workspaces[$i]}" -eq "$cur_wrkspc" ] 2>/dev/null; then
                    cur_pos=$i
                    break
                fi
            done
            if [ "$1" = "--next" ]; then
                trgt_pos=$(( (cur_pos + 1) % tot_valid ))
            else
                trgt_pos=$(( (cur_pos - 1 + tot_valid) % tot_valid ))
            fi
            TRGT_WRKSPC=${valid_workspaces[$trgt_pos]}
            PROCESSED=1
            shift
            ;;
        --name)
            TRGT_WRKSPC=$(( $2 - 1 ))
            PROCESSED=1
            shift 2
            ;;
        *)
            echo "Usage: $0 [--goto] [--mov] [--plus] [--prev] [--next] [--name workspace_number]"
            exit 1
            ;;
    esac
done

if [ $PROCESSED -eq 0 ]; then
    ROFI_LIST=""
    for ((i=0; i<tot_wrkspc; i++)); do
        win_count=0
        if [ -n "$OPEN_WINS_DATA" ]; then
            win_count=$(echo "$OPEN_WINS_DATA" | grep -c -w "$i")
        fi
        if [ "$win_count" -gt 0 ] && [ "$i" -ne "$cur_wrkspc" ]; then
            display_num=$((i + 1))
            if [ -z "$ROFI_LIST" ]; then
                ROFI_LIST="$display_num"
            else
                ROFI_LIST="${ROFI_LIST}\n${display_num}"
            fi
        fi
    done
    if [ "$MOV_WIN_MODE" = true ]; then
        WIN_NM=$(xdotool getwindowname "$TRGT_WIN_ID" 2>/dev/null | cut -c1-30)
        PROMPT_MSG="Move [$WIN_NM] to Workspace"
    else
        PROMPT_MSG="Go to Workspace"
    fi
    ROFI_INPUT=$(echo -e "$ROFI_LIST" | rofi -dmenu -p "$PROMPT_MSG")
    if [ -z "$ROFI_INPUT" ]; then
        exit 0
    fi
    if echo "$ROFI_INPUT" | grep -qE '^[0-9]+$'; then
        TRGT_WRKSPC=$(( ROFI_INPUT - 1 ))
    else
        TRGT_WRKSPC="$ROFI_INPUT"
    fi
fi

if [ -z "$TRGT_WRKSPC" ]; then
    exit 0
fi

if echo "$TRGT_WRKSPC" | grep -qE '^[0-9]+$'; then
    if [ "$TRGT_WRKSPC" -ge "$tot_wrkspc" ]; then
        tot_wrkspc_nu=$((TRGT_WRKSPC + 1))
        xdotool set_num_desktops $tot_wrkspc_nu
    fi
    if [ "$MOV_WIN_MODE" = true ]; then
        xdotool set_desktop_for_window "$TRGT_WIN_ID" "$TRGT_WRKSPC"
    fi
    xdotool set_desktop "$TRGT_WRKSPC"
else
    notify-send "$SCRIPT_NAME" "Error: Invalid input!"
fi
