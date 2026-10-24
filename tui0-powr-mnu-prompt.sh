#!/bin/bash

SCRIPT_NAME="tui0-powr-mnu-prompt.sh"

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Usage: $SCRIPT_NAME <cmd-logout> <cmd-lock> [OPTIONS]"
    echo ""
    echo "Mandatory Arguments:"
    echo "  <cmd-logout>                      Command or path to script executed to logout."
    echo "  <cmd-lock>                        Command or path to script executed to lock."
    echo ""
    echo "Optional Arguments:"
    echo "  --tit=TITLE                       Set custom title prompt."
    echo ""
    exit 0
fi

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Missing mandatory arguments!"
    echo "Usage: $SCRIPT_NAME <cmd-logout> <cmd-lock> [--tit=title]"
    exit 1
fi

CMD_LOGOUT="$1"
CMD_LOCK="$2"
shift 2

TITLE="$SCRIPT_NAME"

for arg in "$@"; do
    case $arg in
        --tit=*)
            TITLE="${arg#*=}"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

declare -A ALL_ACTIONS
ALL_ACTIONS=(
    ["shutdown"]="systemctl poweroff"
    ["reboot"]="systemctl reboot"
    ["suspend"]="systemctl suspend"
    ["logout"]="$CMD_LOGOUT"
    ["lock"]="$CMD_LOCK"
    ["btop"]="lxterminal --geometry=80x28 -e btop"
)

ORDERED_KEYS=("btop" "lock" "logout" "suspend" "reboot" "shutdown")

declare -A ALL_ICONS
ALL_ICONS=(
    ["shutdown"]="system-shutdown"
    ["reboot"]="system-reboot"
    ["suspend"]="system-suspend"
    ["logout"]="system-log-out"
    ["lock"]="system-lock-screen"
    ["btop"]="utilities-system-monitor"
)

CHOICE=$( {
    for key in "${ORDERED_KEYS[@]}"; do
        DISPLAY_NAME=$(echo "$key" | tr '_' ' ')
        ICON_NAME="${ALL_ICONS[$key]}"
        printf "%b\n" "${DISPLAY_NAME}\0icon\x1f${ICON_NAME}"
    done
} | rofi -dmenu -p "$TITLE" -show-icons -i)

if [ -z "$CHOICE" ]; then
    exit 0
fi

ACTION_KEY=$(echo "$CHOICE" | tr ' ' '_')

if [ -n "${ALL_ACTIONS[$ACTION_KEY]}" ]; then
    eval "${ALL_ACTIONS[$ACTION_KEY]}"
else
    notify-send "$SCRIPT_NAME" "Error: Invalid input!"
fi
