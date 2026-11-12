#!/bin/bash

SCRIPT_NAME="powr-mnu.sh"
DIRECT_ACTION=""

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Usage: $SCRIPT_NAME <cmd-logout> <cmd-lock> [DIRECT_ACTION_FLAG] [OPTIONS]"
    echo ""
    echo "Mandatory Arguments:"
    echo "  <cmd-logout>                      Command or path to script executed to logout."
    echo "  <cmd-lock>                        Command or path to script executed to lock."
    echo ""
    echo "Direct Action Flags (Optional - Executes directly without opening menu):"
    echo "  --shutdown, --reboot, --suspend, --logout, --lock, --btop"
    echo ""
    echo "Optional Arguments:"
    echo "  --title=TITLE                     Set custom title prompt."
    echo ""
    exit 0
fi

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Missing mandatory arguments!"
    echo "Usage: $SCRIPT_NAME <cmd-logout> <cmd-lock> [DIRECT_ACTION_FLAG] [--title=title]"
    exit 1
fi

CMD_LOGOUT="$1"
CMD_LOCK="$2"
shift 2

TITLE="$SCRIPT_NAME"

for arg in "$@"; do
    case $arg in
        --shutdown) DIRECT_ACTION="shutdown" ; shift ;;
        --reboot)   DIRECT_ACTION="reboot"   ; shift ;;
        --suspend)  DIRECT_ACTION="suspend"  ; shift ;;
        --logout)   DIRECT_ACTION="logout"   ; shift ;;
        --lock)     DIRECT_ACTION="lock"     ; shift ;;
        --btop)     DIRECT_ACTION="btop"     ; shift ;;
        --title=*)
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
    ["btop"]="lxterminal --geometry=88x28 --working-directory=~ -e btop"
)

declare -A ALL_LABELS
ALL_LABELS=(
    ["btop"]="btop"
    ["lock"]="Lock"
    ["logout"]="Logout"
    ["suspend"]="Suspend"
    ["reboot"]="Reboot"
    ["shutdown"]="Shutdown"
)

declare -A ALL_ICONS
ALL_ICONS=(
    ["shutdown"]="system-shutdown"
    ["reboot"]="system-reboot"
    ["suspend"]="system-suspend"
    ["logout"]="system-log-out"
    ["lock"]="system-lock-screen"
    ["btop"]="utilities-system-monitor"
)

ORDERED_KEYS=("btop" "lock" "logout" "suspend" "reboot" "shutdown")

if [ -n "$DIRECT_ACTION" ]; then
    ACTION_KEY="$DIRECT_ACTION"
else
    CHOICE=$( {
        for key in "${ORDERED_KEYS[@]}"; do
            DISPLAY_NAME="${ALL_LABELS[$key]}"
            ICON_NAME="${ALL_ICONS[$key]}"
            printf "%b\n" "${DISPLAY_NAME}\0icon\x1f${ICON_NAME}"
        done
    } | rofi -dmenu -p "$TITLE" -show-icons -i)

    if [ -z "$CHOICE" ]; then
        exit 0
    fi

    ACTION_KEY=""
    for key in "${!ALL_LABELS[@]}"; do
        if [[ "${ALL_LABELS[$key]}" == "$CHOICE" ]]; then
            ACTION_KEY="$key"
            break
        fi
    done
fi

if [[ "$ACTION_KEY" =~ ^(shutdown|reboot|suspend|logout)$ ]] && ! [[ "$CMD_LOGOUT" == "$HOME/willyhorizont.github.io/linux-debian-lxde/lxsession-logout.sh --logout" && "$ACTION_KEY" == "logout" ]]; then
    $HOME/willyhorizont.github.io/linux/confirm-cmd.sh || exit 1
fi

if [ -n "${ALL_ACTIONS[$ACTION_KEY]}" ]; then
    eval "${ALL_ACTIONS[$ACTION_KEY]}"
else
    notify-send "$SCRIPT_NAME" "Error: Invalid input!"
fi
