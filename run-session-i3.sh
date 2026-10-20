#!/bin/bash

pkill -9 -f "$HOME/willyhorizont.github.io/linux/run-session-i3.sh" 2>/dev/null

CUR_ACTV_WIN_ID=$(xdotool getactivewindow 2>/dev/null)
i3-msg "[id=$CUR_ACTV_WIN_ID] move container to workspace 2"
i3-msg "workspace 2"

i3-msg "exec brave-browser"
while true; do
    wid_brv=$(wmctrl -l -x -G | awk '$7 == "brave-browser.Brave-browser" {print $1}' 2>/dev/null)
    if [ -n "$wid_brv" ]; then
        break
    fi
    sleep 1
done
i3-msg "[id=$wid_brv] move container to workspace 1"
i3-msg "workspace 1"

i3-msg "exec pcmanfm '$HOME/Codes/linux-debian-lxde/'"
i3-msg "exec pcmanfm '$HOME/Codes/linux/'"
i3-msg "exec pcmanfm '$HOME/Pictures/Screenshots'"
while true; do
    wid_fm=$(wmctrl -l -x -G | awk '$7 == "pcmanfm.Pcmanfm" && $9 != "pcmanfm" {print $1}' 2>/dev/null)
    if [ -n "$wid_fm" ]; then
        break
    fi
    sleep 1
done
i3-msg "[class=\"Pcmanfm\"] move container to workspace 2"
i3-msg "workspace 2"

i3-msg "exec code '$HOME/Codes/linux/'"
while true; do
    wid_vsc_lnx=$(wmctrl -l -x -G | awk -v wid_blckls="$wid_vsc_lxde" '$7 == "com.microsoft.vscode.com.microsoft.VSCode" && (index($0, "linux") || index($0, "linux | ~/Codes/linux")) && $1 != wid_blckls {print $1}' 2>/dev/null)
    if [ -n "$wid_vsc_lnx" ]; then
        break
    fi
    sleep 1
done
i3-msg "[id=$wid_vsc_lnx] move container to workspace 3"
i3-msg "workspace 3"

i3-msg "exec code '$HOME/Codes/linux-debian-lxde/'"
while true; do
    wid_vsc_lxde=$(wmctrl -l -x -G | awk '$7 == "com.microsoft.vscode.com.microsoft.VSCode" && (index($0, "linux-debian-lxde") || index($0, "linux-debian-lxde | ~/Codes/linux-debian-lxde")) {print $1}' 2>/dev/null)
    if [ -n "$wid_vsc_lxde" ]; then
        break
    fi
    sleep 1
done
i3-msg "[id=$wid_vsc_lxde] move container to workspace 4"
i3-msg "workspace 4"

i3-msg "workspace 1"
