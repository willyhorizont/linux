#!/bin/bash

$HOME/willyhorizont.github.io/linux/confirm-cmd.sh || exit 1

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
V="0.7.6" # ! DON'T FORGET TO CHANGE VERSION BEFORE RUNNING !!!! run git tag -d "$V" in case accidentally ran
T=$(date "+%d %b %Y @ %I:%M %p")
cd "$RD" || exit

H="
[Last updated: $T][version: $V]
"
H=$(sed -e '/./,$!d' <<< "$H")
# ! DON'T FORGET TO CHANGE COMMIT MESSAGE BEFORE RUNNING !!!!
M="
[new]
add get-open-wins.sh;
add .windowignore to ignore window in wmctrl -l -x -G;
update wrkspc-mgr.sh, use get-open-wins.sh;
update wrkspc-indctr.sh, use get-open-wins.sh;
update kb-tile-cur-ws.sh, use get-open-wins.sh;
update and fix SPRM.awk, add --sep, fix --pref --suff;
update and fix SPRM.c, add --sep, fix --pref --suff;
update and fix SPRM.cpp, add --sep, fix --pref --suff;
update and fix SPRM.pl, add --sep, fix --pref --suff;
update and fix SPRM.py, add --sep, fix --pref --suff;
update and fix SPRM.sh, add --sep, fix --pref --suff;
update and fix SuckMyClock.awk, add --sep, fix --pref --suff;
update and fix SuckMyClock.c, add --sep, fix --pref --suff;
update and fix SuckMyClock.cpp, add --sep, fix --pref --suff;
update and fix SuckMyClock.pl, add --sep, fix --pref --suff;
update and fix SuckMyClock.py, add --sep, fix --pref --suff;
update and fix SuckMyClock.sh, add --sep, fix --pref --suff;
update bt.sh, update --pref --suff;
update net.sh, update --pref --suff;
update cam.sh, update --pref --suff;
update mic.sh, update --pref --suff;
update vol.sh, update --pref --suff;
update powr-indctr.sh, update --pref --suff;

[working on]
add rofi for Windows Task View / Mac Mission Control;
create pinned+opened apps combo rofi;
create non pinned opened apps rofi;
create system tray rofi;

[TODO #1]
create rofi tile-cur-win.sh;
add --pango to --indicator *indctr;
update README.md, add strikethrough to wm that can not be installed via apt install;

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
