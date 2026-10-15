#!/bin/bash

SCREEN_W=$(xdotool getdisplaygeometry | awk '{print $1}')
SCREEN_H=$(xdotool getdisplaygeometry | awk '{print $2}')

echo "SCREEN_W: $SCREEN_W"
echo "SCREEN_H: $SCREEN_H"

WM_DATA=$(wmctrl -d | grep '*')
WORK_AREA=$(echo "$WM_DATA" | grep -oE 'WA: [0-9]+,[0-9]+ [0-9]+x[0-9]+')
# WORK_AREA=$(wmctrl -d | grep '*' | grep -oE 'WA: [0-9]+,[0-9]+ [0-9]+x[0-9]+')
WA_W=$(echo "$WORK_AREA" | awk '{print $3}' | cut -d'x' -f1)
WA_H=$(echo "$WORK_AREA" | awk '{print $3}' | cut -d'x' -f2)
WA_X=$(echo "$WORK_AREA" | awk '{print $2}' | cut -d' ' -f1 | cut -d',' -f1)
WA_Y=$(echo "$WORK_AREA" | awk '{print $2}' | cut -d' ' -f1 | cut -d',' -f2)

echo "wmctrl -d"
wmctrl -d
echo "WORK_AREA: $WORK_AREA"
echo "WA_W: $WA_W"
echo "WA_H: $WA_H"
echo "WA_X: $WA_X"
echo "WA_Y: $WA_Y"
