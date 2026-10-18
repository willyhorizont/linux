#!/bin/bash

xdotool set_num_desktops 1
xdotool set_desktop 0
brave-browser &
xdotool key "ctrl+super+t"
while true; do
    if [ -n "$(wmctrl -l -x -G | awk '$2 == "0" && $7 == "brave-browser.Brave-browser" {print $0}' 2>/dev/null)" ]; then
        break
    fi
    sleep 1
done

xdotool set_num_desktops 2
xdotool set_desktop 1
code "$HOME/Codes/linux/" &
xdotool key "ctrl+super+t"
while true; do
    if [ -n "$(wmctrl -l -x -G | awk '$2 == "1" && $7 == "com.microsoft.vscode.com.microsoft.VSCode" && (index($0, "linux") || index($0, "linux | ~/Codes/linux")) {print $0}' 2>/dev/null)" ]; then
        break
    fi
    sleep 1
done

xdotool set_num_desktops 3
xdotool set_desktop 2
code "$HOME/Codes/linux-debian-lxde/" &
xdotool key "ctrl+super+t"
while true; do
    if [ -n "$(wmctrl -l -x -G | awk '$2 == "2" && $7 == "com.microsoft.vscode.com.microsoft.VSCode" && (index($0, "linux-debian-lxde") || index($0, "linux | ~/Codes/linux-debian-lxde")) {print $0}' 2>/dev/null)" ]; then
        break
    fi
    sleep 1
done

xdotool set_num_desktops 4
xdotool set_desktop 3
pcmanfm "$HOME/Codes/linux-debian-lxde/.config/lxsession/LXDE/" &
pcmanfm "$HOME/Codes/linux-debian-lxde/" &
pcmanfm "$HOME/Codes/linux/" &
pcmanfm "$HOME/Pictures/Screenshots" &
xdotool key "ctrl+super+t"
while true; do
    if [ -n "$(wmctrl -l -x -G | awk '$2 == "3" && $7 == "pcmanfm.Pcmanfm" && index($0, "linux") {print $0}' 2>/dev/null)" ]; then
        break
    fi
    sleep 1
done

xdotool set_num_desktops 5
xdotool set_desktop 4
xdotool key "ctrl+super+r"
xdotool key "ctrl+super+t"
while true; do
    if [ -n "$(wmctrl -l -x -G | awk '$2 == "4" && $7 == "lxterminal.Lxterminal" && index($0, "willy@t430s3520i7m: ~") {print $0}' 2>/dev/null)" ]; then
        break
    fi
    sleep 1
done

xdotool set_desktop 0
