#!/bin/sh

TOOLTIP_TXT=$(cat << EOF
tux-indctr.sh
click to open screensavr-mgr.sh
EOF
)

while true; do
    if pgrep -x "xpenguins" >/dev/null; then
        echo ""
        printf "\e[2J\n" 1>&2
        pidwait -x "xpenguins" 2>/dev/null
    else
        echo "🐧"
        printf "\e[2J%s\n" "$TOOLTIP_TXT" 1>&2
        sleep 1
    fi
done
