#!/bin/bash

xdotool set_num_desktops 1
xdotool set_desktop 0
brave-browser &
sleep 1
xdotool key "ctrl+super+t"

xdotool set_num_desktops 2
xdotool set_desktop 1
code "$HOME/Codes/linux/" &
sleep 1
xdotool key "ctrl+super+t"

xdotool set_num_desktops 3
xdotool set_desktop 2
code "$HOME/Codes/linux-debian-lxde/" &
sleep 1
xdotool key "ctrl+super+t"

xdotool set_num_desktops 4
xdotool set_desktop 3
pcmanfm "$HOME/Codes/linux-debian-lxde/.config/lxsession/LXDE/" &
sleep 0.3
pcmanfm "$HOME/Codes/linux-debian-lxde/" &
sleep 0.3
pcmanfm "$HOME/Codes/linux/" &
sleep 1
xdotool key "ctrl+super+t"

xdotool set_num_desktops 5
xdotool set_desktop 4
xdotool key "ctrl+super+r"
sleep 1
xdotool key "ctrl+super+t"

xdotool set_desktop 0
