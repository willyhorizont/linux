#!/bin/bash

SCRIPT_NAME="tux-indctr.sh"

CMD_CLICK="xfce4-terminal -e $HOME/willyhorizont.github.io/linux/screensavr-mgr.sh"

declare -A ALL_MODES
ALL_MODES=(
    ["tint2"]="tint2"
    ["xfce4-panel"]="xfce4-panel"
)

MODE="${ALL_MODES["tint2"]}"
GENMON_ID=""
USE_PANGO=false
USE_DARK=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --mode)
            if [[ -n "$2" && -n "${ALL_MODES["$2"]}" ]]; then
                MODE="${ALL_MODES["$2"]}"
            fi
            shift 2
            ;;
        --genmon-id) GENMON_ID="$2";  shift 2 ;;
        --pango)     USE_PANGO=true;  shift ;;
        --dark)      USE_DARK=true;   shift ;;
        *)                            shift ;;
    esac
done

TOOLTIP_TXT=$(cat << EOF
$SCRIPT_NAME
click to open screensavr-mgr.sh
EOF
)

print_indicator() {
    local out_txt=""
    case "$DESKTOP_SESSION" in
        LXDE|openbox)
            if pgrep -x "xpenguins" >/dev/null; then
                if [ "$MODE" = "${ALL_MODES["xfce4-panel"]}" ]; then
                    echo "<txt></txt>"
                    echo "<tool></tool>"
                else
                    echo ""
                    printf "\e[2J\n" 1>&2
                fi
            else
                if $USE_PANGO; then
                    if $USE_DARK; then
                        out_txt="<span background='#000000' foreground='#CCFF00'>🐧</span>"
                    else
                        out_txt="<span background='#FFFFFF' foreground='#000000'>🐧</span>"
                    fi
                else
                    out_txt="🐧"
                fi
                if [ "$MODE" = "${ALL_MODES["xfce4-panel"]}" ]; then
                    echo "<txt>${out_txt}</txt>"
                    echo "<txtclick>$CMD_CLICK</txtclick>"
                    echo "<tool>$TOOLTIP_TXT</tool>"
                else
                    echo "${out_txt}"
                    printf "\e[2J%s\n" "$TOOLTIP_TXT" 1>&2
                fi
            fi
            ;;
        *)
            if [ "$MODE" = "${ALL_MODES["xfce4-panel"]}" ]; then
                echo "<txt></txt>"
                echo "<tool></tool>"
            else
                echo ""
                printf "\e[2J\n" 1>&2
            fi
            ;;
    esac
}

print_indicator

case "$DESKTOP_SESSION" in
    LXDE|openbox)
        ;;
    *)
        exit 0
        ;;
esac

if [ "$MODE" = "${ALL_MODES["xfce4-panel"]}" ]; then
    [ -z "$GENMON_ID" ] && exit 0
    pgrep -f ".*pidwait.*xpenguins.*xfce4-panel.*--plugin-event.*:refresh:bool:true.*" >/dev/null && exit 0
    setsid -f bash -c 'while true; do { pgrep -x "xpenguins" >/dev/null && pidwait -x "xpenguins" 2>/dev/null || sleep 1; }; pgrep -x "xfce4-panel" >/dev/null && xfce4-panel --plugin-event="$1:refresh:bool:true" >/dev/null 2>&1; done' _ "$GENMON_ID" >/dev/null 2>&1
    exit 0
fi

while true; do
    if pgrep -x "xpenguins" >/dev/null; then
        pidwait -x "xpenguins" 2>/dev/null
        print_indicator
    else
        sleep 1
        print_indicator
    fi
done
