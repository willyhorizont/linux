#!/bin/bash

if command -v rofi >/dev/null 2>&1; then
    SURE=$(echo -e "No\nYes" | rofi -dmenu -p "Sure" -i -select "No")
    if [ "$SURE" != "Yes" ]; then
        echo "❌ Cancelled."
        exit 1
    fi
    CONFIRM=$(rofi -dmenu -p "Type" -theme-str 'listview {enabled: false;} entry {placeholder: "CONFIRM";}')
else
    read -r -p "Type YES if sure: " SURE
    if [ "$SURE" != "YES" ]; then
        echo "❌ Cancelled."
        exit 1
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
