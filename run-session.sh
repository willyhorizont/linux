#!/bin/bash

pkill -9 -f "$HOME/willyhorizont.github.io/linux/run-session.sh" 2>/dev/null

xdotool set_num_desktops 5

brave-browser &
while true; do
    wid_brv=$(wmctrl -l -x -G | awk '$7 == "brave-browser.Brave-browser" {print $1}' 2>/dev/null)
    if [ -n "$wid_brv" ]; then
        break
    fi
    sleep 1
done
xdotool set_num_desktops 5
xdotool set_desktop_for_window "$wid_brv" 0
xdotool set_desktop 0
xdotool key "ctrl+super+f"

code "$HOME/Codes/linux-debian-lxde/" &
while true; do
    wid_vsc_lxde=$(wmctrl -l -x -G | awk '$7 == "com.microsoft.vscode.com.microsoft.VSCode" && (index($0, "linux-debian-lxde") || index($0, "linux-debian-lxde | ~/Codes/linux-debian-lxde")) {print $1}' 2>/dev/null)
    if [ -n "$wid_vsc_lxde" ]; then
        break
    fi
    sleep 1
done
xdotool set_num_desktops 5
xdotool set_desktop_for_window "$wid_vsc_lxde" 2
xdotool set_desktop 2
xdotool key "ctrl+super+f"

pcmanfm "$HOME/Codes/linux-debian-lxde/" &
pcmanfm "$HOME/Codes/linux/" &
pcmanfm "$HOME/Pictures/Screenshots" &
while true; do
    wid_fm=$(wmctrl -l -x -G | awk '$7 == "pcmanfm.Pcmanfm" && $9 != "pcmanfm" {print $1}' 2>/dev/null)
    if [ -n "$wid_fm" ]; then
        break
    fi
    sleep 1
done
xdotool set_num_desktops 5
xdotool set_desktop_for_window "$wid_fm" 3
xdotool set_desktop 3
xdotool key "ctrl+super+f"

lxterminal --working-directory=~ &
while true; do
    wid_trm=$(wmctrl -l -x -G | awk '$7 == "lxterminal.Lxterminal" {print $1}' 2>/dev/null)
    if [ -n "$wid_trm" ]; then
        break
    fi
    sleep 1
done
xdotool set_num_desktops 5
xdotool set_desktop_for_window "$wid_trm" 4
xdotool set_desktop 4
xdotool key "ctrl+super+f"

code "$HOME/Codes/linux/" &
while true; do
    wid_vsc_lnx=$(wmctrl -l -x -G | awk -v wid_blckls="$wid_vsc_lxde" '$7 == "com.microsoft.vscode.com.microsoft.VSCode" && (index($0, "linux") || index($0, "linux | ~/Codes/linux")) && $1 != wid_blckls {print $1}' 2>/dev/null)
    if [ -n "$wid_vsc_lnx" ]; then
        break
    fi
    sleep 1
done
xdotool set_num_desktops 5
xdotool set_desktop_for_window "$wid_vsc_lnx" 1
xdotool set_desktop 1
xdotool key "ctrl+super+f"
