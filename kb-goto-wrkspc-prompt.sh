#!/bin/bash

SCRIPT_NAME="kb-goto-wrkspc-prompt.sh"

tot_wrkspc=$(xdotool get_num_desktops)
curr_wrkspc=$(xdotool get_desktop)

PROCESSED=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p)
            TRGT_WRKSPC=$(( $2 - 1 ))
            PROCESSED=1
            shift 2
            ;;
        --prev)
            TRGT_WRKSPC=$(( (curr_wrkspc - 1 + tot_wrkspc) % tot_wrkspc ))
            PROCESSED=1
            shift
            ;;
        --next)
            TRGT_WRKSPC=$(( (curr_wrkspc + 1) % tot_wrkspc ))
            PROCESSED=1
            shift
            ;;
        *)
            echo "Usage: $0 [-p workspace_number] [--prev] [--next]"
            exit 1
            ;;
    esac
done

if [ $PROCESSED -eq 0 ]; then
    ACTIVE_WRKSPCS=$(seq 1 "$tot_wrkspc")
    ROFI_INPUT=$(echo "$ACTIVE_WRKSPCS" | rofi -dmenu -p "Go to Workspace")
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
    xdotool set_desktop "$TRGT_WRKSPC"
else
    notify-send "$SCRIPT_NAME" "Error: Invalid input!"
fi
