#!/bin/bash

xdotool set_num_desktops 4

pid_brv=$(wmctrl -l -x -G -p | awk '$8 == "brave-browser.Brave-browser" {print $3}' 2>/dev/null)
if [ -z "$pid_brv" ]; then
    brave-browser &
fi
while true; do
    wid_brv=$(wmctrl -l -x -G | awk '$7 == "brave-browser.Brave-browser" {print $1}' 2>/dev/null)
    if [ -n "$wid_brv" ]; then
        break
    fi
    sleep 0.2
done
xdotool set_num_desktops 4
xdotool set_desktop_for_window "$wid_brv" 0
xdotool set_desktop 0
xdotool key "ctrl+super+f"

pid_fm=$(wmctrl -l -x -G -p | awk '$8 == "pcmanfm.Pcmanfm" && $10 != "pcmanfm" {print $3}' 2>/dev/null)
if [ -n "$pids_fm" ]; then
    echo "$pids_fm" | while read -r pid; do
        if [ -n "$pid" ]; then
            kill -9 "$pid" 2>/dev/null
        fi
    done
fi
pcmanfm "$HOME/Codes/linux-debian-lxde/" &
pcmanfm "$HOME/Codes/linux/" &
pcmanfm "$HOME/Pictures/Screenshots" &
while true; do
    wid_fm=$(wmctrl -l -x -G | awk '$7 == "pcmanfm.Pcmanfm" && $9 != "pcmanfm" {print $1}' 2>/dev/null)
    if [ -n "$wid_fm" ]; then
        break
    fi
    sleep 0.2
done
xdotool set_num_desktops 4
xdotool set_desktop_for_window "$wid_fm" 1
xdotool set_desktop 1
xdotool key "ctrl+super+f"

pkill -9 -x lxterminal 2>/dev/null
lxterminal --working-directory=~ &
while true; do
    wid_trm=$(wmctrl -l -x -G | awk '$7 == "lxterminal.Lxterminal" {print $1}' 2>/dev/null)
    if [ -n "$wid_trm" ]; then
        break
    fi
    sleep 0.2
done
xdotool set_num_desktops 4
xdotool set_desktop_for_window "$wid_trm" 1
xdotool set_desktop 1
xdotool key "ctrl+super+t"

pid_vsc_lxde=$(wmctrl -l -x -G -p | awk '$8 == "com.microsoft.vscode.com.microsoft.VSCode" && (index($0, "linux-debian-lxde") || index($0, "linux-debian-lxde | ~/Codes/linux-debian-lxde")) {print $3}' 2>/dev/null)
if [ -z "$pid_vsc_lxde" ]; then
    code "$HOME/Codes/linux-debian-lxde/" &
fi
while true; do
    wid_vsc_lxde=$(wmctrl -l -x -G | awk '$7 == "com.microsoft.vscode.com.microsoft.VSCode" && (index($0, "linux-debian-lxde") || index($0, "linux-debian-lxde | ~/Codes/linux-debian-lxde")) {print $1}' 2>/dev/null)
    if [ -n "$wid_vsc_lxde" ]; then
        break
    fi
    sleep 0.2
done
xdotool set_num_desktops 4
xdotool set_desktop_for_window "$wid_vsc_lxde" 3
xdotool set_desktop 3
xdotool key "ctrl+super+f"

pid_vsc_lnx=$(wmctrl -l -x -G -p | awk -v wid_blckls="$wid_vsc_lxde" '$8 == "com.microsoft.vscode.com.microsoft.VSCode" && (index($0, "linux") || index($0, "linux | ~/Codes/linux")) && $1 != wid_blckls {print $3}' 2>/dev/null)
if [ -z "$pid_vsc_lnx" ]; then
    code "$HOME/Codes/linux/" &
fi
while true; do
    wid_vsc_lnx=$(wmctrl -l -x -G | awk -v wid_blckls="$wid_vsc_lxde" '$7 == "com.microsoft.vscode.com.microsoft.VSCode" && (index($0, "linux") || index($0, "linux | ~/Codes/linux")) && $1 != wid_blckls {print $1}' 2>/dev/null)
    if [ -n "$wid_vsc_lnx" ]; then
        break
    fi
    sleep 0.2
done
xdotool set_num_desktops 4
xdotool set_desktop_for_window "$wid_vsc_lnx" 2
xdotool set_desktop 2
xdotool key "ctrl+super+f"

xdotool set_desktop 0
