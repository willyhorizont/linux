#!/bin/bash

SURE=$(echo -e "No\nYes" | rofi -dmenu -p "Sure" -i -select "No")

if [ "$SURE" != "Yes" ]; then
    exit 1
fi

CONFIRM=$(rofi -dmenu -p "Type" -theme-str 'listview {enabled: false;} entry {placeholder: "CONFIRM";}')

if [ "$CONFIRM" == "CONFIRM" ]; then
    echo "✅ Confirmed."
    exit 0
else
    echo "❌ Cancelled."
    exit 1
fi
