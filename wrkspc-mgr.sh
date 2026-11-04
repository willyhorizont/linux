#!/bin/bash

SCRIPT_NAME="wrkspc-mgr.sh"

if ! command -v xdotool >/dev/null 2>&1 || ! command -v wmctrl >/dev/null 2>&1 || ! command -v xprop >/dev/null 2>&1; then
    notify-send "[$SCRIPT_NAME]" "Error: missing dependencies 'xdotool wmctrl xprop'..."
    exit 1
fi

tot_wrkspc=$(xdotool get_num_desktops)
cur_wrkspc=$(xdotool get_desktop)

OPEN_WINS_DATA=$("$HOME/willyhorizont.github.io/linux/get-open-wins.sh" | awk '{print $2}')

PROCESSED=0
MOV_WIN_MODE=false
TRGT_WIN_ID=""
BYNAME_MODE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --byname)
            BYNAME_MODE=true
            shift
            ;;
        --goto)
            PROCESSED=1
            shift
            ;;
        --mov)
            MOV_WIN_MODE=true
            TRGT_WIN_ID=$(xdotool getactivewindow 2>/dev/null)
            if [ -z "$TRGT_WIN_ID" ]; then
                notify-send "[$SCRIPT_NAME]" "Error: active window not found!"
                exit 1
            fi
            PROCESSED=1
            shift
            ;;
        --plus)
            if [ "$BYNAME_MODE" = true ]; then
                max_ws=$(xprop -root _NET_DESKTOP_NAMES 2>/dev/null | awk -F'"' '{
                    for(i=2; i<=NF; i+=2) {
                        if (match($i, /[0-9]+/)) {
                            num = substr($i, RSTART, RLENGTH);
                            print num;
                        }
                    }
                }' | sort -rn | head -n 1)
                if [ -z "$max_ws" ]; then max_ws=0; fi
                TRGT_WRKSPC=$(( max_ws + 1 ))
            else
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
            fi
            PROCESSED=1
            shift
            ;;
        --next|--prev)
            if [ "$BYNAME_MODE" = true ]; then
                mapfile -t valid_workspaces < <(xprop -root _NET_DESKTOP_NAMES 2>/dev/null | awk -F'"' '{for(i=2; i<=NF; i+=2) print $i}')
                cur_idx=$(xprop -root _NET_CURRENT_DESKTOP | awk '{print $3}')
                cur_ws_name=${valid_workspaces[$cur_idx]}
                tot_valid=${#valid_workspaces[@]}
                cur_pos=0
                for i in "${!valid_workspaces[@]}"; do
                    if [ "${valid_workspaces[$i]}" = "$cur_ws_name" ]; then
                        cur_pos=$i
                        break
                    fi
                done
                if [ "$1" = "--next" ]; then
                    trgt_pos=$(( (cur_pos + 1) % tot_valid ))
                else
                    trgt_pos=$(( (cur_pos - 1 + tot_valid) % tot_valid ))
                fi
                for i in "${!valid_workspaces[@]}"; do
                    if [ "${valid_workspaces[$i]}" = "${valid_workspaces[$trgt_pos]}" ]; then
                        TRGT_WRKSPC=$i
                        break
                    fi
                done
            else
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
            fi
            PROCESSED=1
            shift
            ;;
        --number)
            if ! echo "$2" | grep -qE '^[0-9]+$'; then
                notify-send "[$SCRIPT_NAME]" "Error: invalid arguments!"
                exit 1
            fi
            if [ "$BYNAME_MODE" = true ] && [ -n "$2" ]; then
                WS_NAME_BY_IDX=$(xprop -root _NET_DESKTOP_NAMES 2>/dev/null | awk -v idx="$2" -F'"' '{print $(2 * (idx - 1) + 2)}')
                if [ -n "$WS_NAME_BY_IDX" ]; then
                    mapfile -t all_ws_names < <(xprop -root _NET_DESKTOP_NAMES 2>/dev/null | awk -F'"' '{for(i=2; i<=NF; i+=2) print $i}')
                    for i in "${!all_ws_names[@]}"; do
                        if [ "${all_ws_names[$i]}" = "$WS_NAME_BY_IDX" ]; then
                            TRGT_WRKSPC=$i
                            break
                        fi
                    done
                fi
                if [ -z "$TRGT_WRKSPC" ]; then TRGT_WRKSPC=$(( $2 - 1 )); fi
            else
                TRGT_WRKSPC=$(( $2 - 1 ))
            fi
            PROCESSED=1
            shift 2
            ;;
        *)
            echo "Usage: $0 [--byname] [--goto] [--mov] [--plus] [--prev] [--next] [--number workspace_number]"
            exit 1
            ;;
    esac
done

if [ -z "$TRGT_WRKSPC" ]; then
    PROCESSED=0
fi

if [ $PROCESSED -eq 0 ]; then
    ROFI_LIST=""
    if [ "$BYNAME_MODE" = true ]; then
        ROFI_LIST=$(xprop -root _NET_DESKTOP_NAMES 2>/dev/null | awk -F'"' '{for(i=2; i<=NF; i+=2) print $i}' | tr '\n' '\\' | sed 's/\\/\\n/g' | sed 's/\\n$//')
    else
        for ((i=0; i<tot_wrkspc; i++)); do
            win_count=0
            if [ -n "$OPEN_WINS_DATA" ]; then
                win_count=$(echo "$OPEN_WINS_DATA" | grep -c -w "$i")
            fi
            if [ "$win_count" -gt 0 ]; then
                display_num=$((i + 1))
                if [ -z "$ROFI_LIST" ]; then
                    ROFI_LIST="$display_num"
                else
                    ROFI_LIST="${ROFI_LIST}\n${display_num}"
                fi
            fi
        done
    fi

    if [ "$MOV_WIN_MODE" = true ]; then
        FULL_NM=$(xdotool getwindowname "$TRGT_WIN_ID" 2>/dev/null)
        if [ ${#FULL_NM} -gt 43 ]; then
            WIN_NM="${FULL_NM:0:20}...${FULL_NM: -20}"
        else
            WIN_NM="$FULL_NM"
        fi
        WM_CLASS=$(xprop -id "$TRGT_WIN_ID" WM_CLASS 2>/dev/null | awk -F'"' '{print $4}')
        if [ -n "$WM_CLASS" ]; then
            WIN_NM="$WM_CLASS | $WIN_NM"
        fi
        PROMPT_MSG="Move [$WIN_NM] to Workspace"
    else
        PROMPT_MSG="Go to Workspace"
    fi
    ROFI_INPUT=$(echo -e "$ROFI_LIST" | rofi -dmenu -p "$PROMPT_MSG")
    if [ -z "$ROFI_INPUT" ]; then
        exit 0
    fi

    if [ "$BYNAME_MODE" = true ]; then
        mapfile -t all_ws_names < <(xprop -root _NET_DESKTOP_NAMES 2>/dev/null | awk -F'"' '{for(i=2; i<=NF; i+=2) print $i}')
        for i in "${!all_ws_names[@]}"; do
            if [ "${all_ws_names[$i]}" = "$ROFI_INPUT" ]; then
                TRGT_WRKSPC=$i
                break
            fi
        done
        if [ -z "$TRGT_WRKSPC" ]; then TRGT_WRKSPC="$ROFI_INPUT"; fi
    else
        if echo "$ROFI_INPUT" | grep -qE '^[0-9]+$'; then
            TRGT_WRKSPC=$(( ROFI_INPUT - 1 ))
        else
            TRGT_WRKSPC="$ROFI_INPUT"
        fi
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
    notify-send "[$SCRIPT_NAME]" "Error: invalid input!"
fi
