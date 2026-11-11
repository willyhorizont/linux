#!/bin/sh

TOOLTIP_TXT=$(cat << EOF
tux-indctr.sh
click to open screensavr-mgr.sh
EOF
)
if pgrep -x "xpenguins" >/dev/null; then
    echo ""
    printf "" 1>&2
else
    echo "🐧"
    printf "%s" "$TOOLTIP_TXT" 1>&2
fi
