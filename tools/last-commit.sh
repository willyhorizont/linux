#!/bin/bash

$HOME/willyhorizont.github.io/linux/confirm-cmd.sh --msg "Confirm Commit" || exit 1

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
V="0.11.0" # ! DON'T FORGET TO CHANGE VERSION BEFORE RUNNING !!!! run git tag -d "$V" in case accidentally ran
T=$(date "+%d %b %Y @ %I:%M %p")
cd "$RD" || exit

H="
[Last updated: $T][version: $V]
"
H=$(sed -e '/./,$!d' <<< "$H")
# ! DON'T FORGET TO CHANGE COMMIT MESSAGE BEFORE RUNNING !!!!
M="
[new]
-- replace wmctrl -d to xprop -root _NET_DESKTOP_NAMES --, done;
-- rename wmctrl-lxcapg.sh to wmctrl-lxpcapg.sh, update wmctrl -l -x -G to wmctrl -l -x -p -G --, canceled;
replace lxterminal with xfce4-terminal;
replace wmctrl-lxpcapg.sh and get-open-wins.sh to wmctrl -l -x -G for lxde openbox non display;

[working on]

[TODO #1]
create rofi tile-cur-win.sh;
create rofi Windows Notification Area or System Tray / Mac Menu Bar Extras or Status Menus / Linux Status Notifier Area or System Tray;

[TODO #2]
add rofi grid for Windows Start Menu / Mac Launchpad;
try skippy-xd for Windows Task View / Mac Mission Control;
dvd screensaver;
try panel with signal support, IPC?;

[TODO #3]
check *openbox*.sh, remove openbox part if not related;
rename script to job*, kb*, indic*, to match indic*, tui*;
remove separate config and move it to the code instead;
cleanup dev/*
cleanup *i3*
"
M=$(sed -e '/./,$!d' <<< "$M")
M="$H
$M"
touch "$RD/changelog.txt" && awk -v msg="$M" 'BEGIN {print msg; print ""} {print}' "$RD/changelog.txt" > "$RD/changelog.tmp" && mv "$RD/changelog.tmp" "$RD/changelog.txt"
git add changelog.txt
git add .
git commit -m "$M"
git tag -d "$V" 2>/dev/null
git tag -a "$V" -m "$M"
git push origin main
git push origin --tags
