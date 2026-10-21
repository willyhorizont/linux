#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
V="0.5.12" # ! DON'T FORGET TO CHANGE VERSION BEFORE RUNNING !!!! run git tag -d "$V" in case accidentally ran
T=$(date "+%d %b %Y @ %I:%M %p")
cd "$RD" || exit

H="
[Last updated: $T][version: $V]
"
H=$(sed -e '/./,$!d' <<< "$H")
# ! DON'T FORGET TO CHANGE COMMIT MESSAGE BEFORE RUNNING !!!!
M="
fix lxde openbox autostart;
update tui0-powr-mnu-prompt.sh, remove cancel;
update cheatsheet, add see command history, add Disable GRUB_TIMEOUT;
add undo last commit cheatsheet;
update sleep;
update dmn-lockr.sh, update sleep;
update indic0-wrkspc.sh, update sleep;
update run-session.sh, update sleep;
update run-session-i3.sh, update sleep;
add wmctrl-lxcapg.sh;
remove 5s timeout debian;

TODO #1:
touch kb-cnfrm-cls.sh;
merge dmn-wrkspc-mgr.sh to indic0-wrkspc.sh, and delete dmn-wrkspc-mgr.sh;
TODO #2:
update indic0-wrkspc.sh, update to read file on RMB click and add keybind to set the text content, add dmn-wrkspc-mgr.sh;
add --eco to indic* SPRM to read file on RMB click and add keybind to set the text content;
touch kb-update-indic.sh;
TODO #3:
make window font size smaller;
check *openbox*.sh, remove openbox part if not related;
rename script to job*, kb*, indic*, to match indic*, tui*;
remove separate config and move it to the code instead;
add time on terminal;
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
