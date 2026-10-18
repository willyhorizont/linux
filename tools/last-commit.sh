#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
V="0.5.7" # ! DON'T FORGET TO CHANGE VERSION BEFORE RUNNING !!!! run git tag -d "$V" in case accidentally ran
T=$(date "+%d %b %Y @ %I:%M %p")
cd "$RD" || exit

H="
[Last updated: $T][version: $V]
"
H=$(sed -e '/./,$!d' <<< "$H")
# ! DON'T FORGET TO CHANGE COMMIT MESSAGE BEFORE RUNNING !!!!
M="
update and fix run-session.sh;
small update kb-tile-cur-wrkspc.sh;

canceled:
add abillity to navigate through tiles;
add abillity to move tile;
reason:
tried to nav tile but no way to track detached tiles;
tried to mov tile but no way to track detached tiles;

TODO:
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
