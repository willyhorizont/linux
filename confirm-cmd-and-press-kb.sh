#!/bin/sh

SCRIPT_NAME="confirm-cmd-and-press-kb.sh"

if ! command -v xdotool >/dev/null 2>&1; then
    notify-send "$SCRIPT_NAME" "Error: missing dependencies 'xdotool'..."
    exit 1
fi

kb=""
msg="Confirm Action"

while [ $# -gt 0 ]; do
    case "$1" in
        --msg) msg="$2"; shift 2 ;;
        *)      kb="$1"; shift   ;;
    esac
done

if [ -z "$msg" ]; then
    msg="Confirm Action"
fi

if [ -z "$kb" ]; then
    notify-send "$SCRIPT_NAME" "Usage: $SCRIPT_NAME <kb> [--msg message]"
    exit 1
fi

"$HOME/willyhorizont.github.io/linux/confirm-cmd.sh" --confirm --msg "$msg" || exit 1

sleep 0.2

xdotool key "$kb"
