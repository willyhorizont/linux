#!/bin/bash

echo "mic=?      | "

MIC_VOL=$(pactl get-source-volume @DEFAULT_SOURCE@ 2>/dev/null | awk '{print $5}' | tr -d '%')
MIC_MUTE=$(pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | awk '{print $2}')

if [ -z "$MIC_VOL" ]; then
    echo "mic=X      | "
    exit 0
fi

MIC_PAD=$(printf "%3d" "$MIC_VOL")

if [ "$MIC_MUTE" = "yes" ]; then
    echo "mic=N $MIC_PAD% | "
else
    echo "mic=Y $MIC_PAD% | "
fi
