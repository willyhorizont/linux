#!/bin/bash

IS_CONFIRM=false
MSG="Confirm"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --msg)       MSG="$2";         shift 2 ;;
        --confirm)   IS_CONFIRM=true;  shift ;;
        *)                             shift ;;
    esac
done

if command -v rofi >/dev/null 2>&1; then
    CONFIRM=$(echo -e "No\nYes" | rofi -dmenu -p "$MSG" -i -select "No")
    if [ "$CONFIRM" != "Yes" ]; then
        echo "❌ Cancelled."
        exit 1
    fi
    if [ "$IS_CONFIRM" = true ]; then
        echo "✅ Confirmed."
        exit 0
    fi
    DOUBLE_CONFIRM=$(rofi -dmenu -p "Type" -theme-str 'listview {enabled: false;} entry {placeholder: "CONFIRM";}')
else
    read -r -p "Type YES to proceed: " CONFIRM
    if [ "$CONFIRM" != "YES" ]; then
        echo "❌ Cancelled."
        exit 1
    fi
    if [ "$IS_CONFIRM" = true ]; then
        echo "✅ Confirmed."
        exit 0
    fi
    read -r -p "Type CONFIRM to proceed: " DOUBLE_CONFIRM
fi

if [ "$DOUBLE_CONFIRM" == "CONFIRM" ]; then
    echo "✅ Confirmed."
    exit 0
else
    echo "❌ Cancelled."
    exit 1
fi
