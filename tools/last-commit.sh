#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
V="0.1.0" # ! DON'T FORGET TO CHANGE VERSION BEFORE RUNNING !!!! run git tag -d "$V" in case accidentally ran
T=$(date "+%d %b %Y @ %I:%M %p")
cd "$RD" || exit

H="
[Last updated: $T][version: $V]
"
H=$(sed -e '/./,$!d' <<< "$H")
# ! DON'T FORGET TO CHANGE COMMIT MESSAGE BEFORE RUNNING !!!!
M="
update indic0-tux.sh;
update indic1-bt.sh;
update indic2-net.sh;
update indic3-cam.sh;
update indic4-mic.sh;
update indic5-vol.sh;
update indic6-powr.sh;
add tui-bat-lenovo-thinkpad.sh;
add tui0-tux.sh;
update tui1-bt.sh;
update tui2-net.sh;
add tui3-cam.sh;
add tui4-mic.sh;
add tui5-vol.sh;
add tui6-powr.sh;
update SPRM.c, add tooltip via stderr;
update SPRM.cpp, add tooltip via stderr;
update and fix SPRM.awk, add tooltip via stderr;
update SPRM.pl, add tooltip via stderr;
update SPRM.py, add tooltip via stderr;
update SPRM.sh, add tooltip via stderr;
update SuckMyClock.c, add tooltip via stderr;
update SuckMyClock.cpp, add tooltip via stderr;
update SuckMyClock.awk, add tooltip via stderr;
update SuckMyClock.pl, add tooltip via stderr;
update SuckMyClock.py, add tooltip via stderr;
update SuckMyClock.sh, add tooltip via stderr;
update indic*, add tooltip via stderr;
update README.md, add SPRM SuckMyClock indic* tui*;
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
