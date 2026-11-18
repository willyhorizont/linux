#!/bin/bash

IS_CONFIRM=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --confirm)   IS_CONFIRM=true;  shift ;;
        *)                             shift ;;
    esac
done

if command -v rofi >/dev/null 2>&1; then
    SURE=$(echo -e "No\nYes" | rofi -dmenu -p "Sure" -i -select "No")
    if [ "$SURE" != "Yes" ]; then
        echo "❌ Cancelled."
        exit 1
    fi
    if [ "$IS_CONFIRM" = true ]; then
        echo "✅ Confirmed."
        exit 0
    fi
    CONFIRM=$(rofi -dmenu -p "Type" -theme-str 'listview {enabled: false;} entry {placeholder: "CONFIRM";}')
else
    read -r -p "Type YES if sure: " SURE
    if [ "$SURE" != "YES" ]; then
        echo "❌ Cancelled."
        exit 1
    fi
    if [ "$IS_CONFIRM" = true ]; then
        echo "✅ Confirmed."
        exit 0
    fi
    read -r -p "Type CONFIRM to proceed: " CONFIRM
fi

if [ "$CONFIRM" == "CONFIRM" ]; then
    echo "✅ Confirmed."
    exit 0
else
    echo "❌ Cancelled."
    exit 1
fi
