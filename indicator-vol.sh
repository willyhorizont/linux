#!/bin/bash

VOL=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk '{print $5}' | tr -d '%')
SINK_MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}')

if [ -z "$VOL" ]; then
    echo "vol=X      | "
    exit 0
fi

VOL_PAD=$(printf "%3d" "$VOL")

if [ "$SINK_MUTE" = "yes" ]; then
    echo "vol=N $VOL_PAD% | "
else
    echo "vol=Y $VOL_PAD% | "
fi
