#!/bin/bash

pkill -9 -f "$HOME/willyhorizont.github.io/linux/run-session-i3.sh" 2>/dev/null

CUR_ACTV_WIN_ID=$(xdotool getactivewindow 2>/dev/null)
i3-msg "[id=$CUR_ACTV_WIN_ID] move container to workspace 2"
i3-msg "workspace 2"

pid_brv=$(wmctrl -l -x -G -p | awk '$8 == "brave-browser.Brave-browser" {print $3}' 2>/dev/null)
if [ -z "$pid_brv" ]; then
    i3-msg "exec brave-browser"
fi
while true; do
    wid_brv=$(wmctrl -l -x -G | awk '$7 == "brave-browser.Brave-browser" {print $1}' 2>/dev/null)
    if [ -n "$wid_brv" ]; then
        break
    fi
    sleep 0.2
done
i3-msg "[id=$wid_brv] move container to workspace 1"
i3-msg "workspace 1"

pids_fm=$(wmctrl -l -x -G -p | awk '$8 == "pcmanfm.Pcmanfm" && $10 != "pcmanfm" {print $3}' 2>/dev/null)
if [ -n "$pids_fm" ]; then
    echo "$pids_fm" | while read -r pid; do
        if [ -n "$pid" ]; then
            kill -9 "$pid" 2>/dev/null
        fi
    done
fi
i3-msg "exec pcmanfm '$HOME/Codes/linux-debian-lxde/'"
i3-msg "exec pcmanfm '$HOME/Codes/linux/'"
i3-msg "exec pcmanfm '$HOME/Pictures/Screenshots'"
while true; do
    wid_fm=$(wmctrl -l -x -G | awk '$7 == "pcmanfm.Pcmanfm" && $9 != "pcmanfm" {print $1}' 2>/dev/null)
    if [ -n "$wid_fm" ]; then
        break
    fi
    sleep 0.2
done
i3-msg "[class=\"Pcmanfm\"] move container to workspace 2"
i3-msg "workspace 2"

pkill -9 -x lxterminal 2>/dev/null
i3-msg "exec lxterminal --working-directory=~"
while true; do
    wid_trm=$(wmctrl -l -x -G | awk '$7 == "lxterminal.Lxterminal" {print $1}' 2>/dev/null)
    if [ -n "$wid_trm" ]; then
        break
    fi
    sleep 0.2
done
i3-msg "[id=$wid_trm] move container to workspace 2"
i3-msg "workspace 2"

pid_vsc_lxde=$(wmctrl -l -x -G -p | awk '$8 == "com.microsoft.vscode.com.microsoft.VSCode" && (index($0, "linux-debian-lxde") || index($0, "linux-debian-lxde | ~/Codes/linux-debian-lxde")) {print $3}' 2>/dev/null)
if [ -z "$pid_vsc_lxde" ]; then
    i3-msg "exec code '$HOME/Codes/linux-debian-lxde/'"
fi
while true; do
    wid_vsc_lxde=$(wmctrl -l -x -G | awk '$7 == "com.microsoft.vscode.com.microsoft.VSCode" && (index($0, "linux-debian-lxde") || index($0, "linux-debian-lxde | ~/Codes/linux-debian-lxde")) {print $1}' 2>/dev/null)
    if [ -n "$wid_vsc_lxde" ]; then
        break
    fi
    sleep 0.2
done
i3-msg "[id=$wid_vsc_lxde] move container to workspace 4"
i3-msg "workspace 4"

pid_vsc_lnx=$(wmctrl -l -x -G -p | awk -v wid_blckls="$wid_vsc_lxde" '$8 == "com.microsoft.vscode.com.microsoft.VSCode" && (index($0, "linux") || index($0, "linux | ~/Codes/linux")) && $1 != wid_blckls {print $3}' 2>/dev/null)
if [ -z "$pid_vsc_lnx" ]; then
    i3-msg "exec code '$HOME/Codes/linux/'"
fi
while true; do
    wid_vsc_lnx=$(wmctrl -l -x -G | awk -v wid_blckls="$wid_vsc_lxde" '$7 == "com.microsoft.vscode.com.microsoft.VSCode" && (index($0, "linux") || index($0, "linux | ~/Codes/linux")) && $1 != wid_blckls {print $1}' 2>/dev/null)
    if [ -n "$wid_vsc_lnx" ]; then
        break
    fi
    sleep 0.2
done
i3-msg "[id=$wid_vsc_lnx] move container to workspace 3"
i3-msg "workspace 3"

i3-msg "workspace 1"
