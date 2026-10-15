#!/bin/bash

wmctrl -l -x -G | awk '!( ($7 == "pcmanfm.Pcmanfm" && $9 == "pcmanfm") || ($7 == "plank.Plank" && $9 == "plank") || ($7 == "tint2.Tint2") || ($7 == "xpenguins.Xpenguins") || ($8 ~ /welcome-window|idle-window/) )'
