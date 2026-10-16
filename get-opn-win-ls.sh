#!/bin/bash

OPEN_WINS=$(wmctrl -l -x -G | awk '
{
    if ($7 == "pcmanfm.Pcmanfm" && $9 == "pcmanfm") next;
    if ($7 == "plank.Plank" && $9 == "plank") next;
    if ($7 == "tint2.Tint2") next;
    if ($7 == "xpenguins.Xpenguins") next;
    if ($7 ~ /welcome-window|idle-window/) next;
    print $0
}' 2>/dev/null)
echo "$OPEN_WINS"
