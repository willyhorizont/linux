#!/bin/bash

while true; do
    read -sp "ARE YOU SURE: " PASS1
    echo ""
    
    if [ -z "$PASS1" ]; then
        echo "❌ Password empty! Please try again."
        echo ""
        continue
    fi

    read -sp "ARE YOU SUPER SURE: " PASS2
    echo ""

    if [ "$PASS1" == "$PASS2" ]; then
        echo "✅ Password match. I hope you super duper sure..."
        echo ""
        break
    else
        echo "❌ Password not match! Please try again."
        echo ""
    fi
done

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
V="0.7.2" # ! DON'T FORGET TO CHANGE VERSION BEFORE RUNNING !!!! run git tag -d "$V" in case accidentally ran
T=$(date "+%d %b %Y @ %I:%M %p")
cd "$RD" || exit

H="
[Last updated: $T][version: $V]
"
H=$(sed -e '/./,$!d' <<< "$H")
# ! DON'T FORGET TO CHANGE COMMIT MESSAGE BEFORE RUNNING !!!!
M="
--add time on terminal--;
--remove space between months and days in SuckMyClock--;
update uptime.c, remove minutes pad;
update uptime.cpp, remove minutes pad;
update uptime.awk, remove minutes pad;
update uptime.pl, remove minutes pad;
update uptime.py, remove minutes pad;
update uptime.sh, remove minutes pad;
update kb-tile-cur-wrkspc.sh, update tile keybind;

working on:
add confirm-cmd.sh;
add rofi for Windows Task View / Mac Mission Control;
create pinned+opened apps combo rofi;
create other opened apps rofi;
create rofi tile-cur-win.sh;
add --pango to --indicator *indctr;

TODO #1:
update README.md, add strikethrough to wm that can not be installed via apt install;
TODO #2:
add rofi grid for Windows Start Menu / Mac Launchpad;
try skippy-xd for Windows Task View / Mac Mission Control;
dvd screensaver;
try panel with signal support, IPC?;
TODO #3:
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
