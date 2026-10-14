#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
V="0.3.5" # ! DON'T FORGET TO CHANGE VERSION BEFORE RUNNING !!!! run git tag -d "$V" in case accidentally ran
T=$(date "+%d %b %Y @ %I:%M %p")
cd "$RD" || exit

H="
[Last updated: $T][version: $V]
"
H=$(sed -e '/./,$!d' <<< "$H")
# ! DON'T FORGET TO CHANGE COMMIT MESSAGE BEFORE RUNNING !!!!
M="
add cln-trl-wrkspc.sh;
add indic0-wrkspc.sh;
add dmn-openbox-wrkspc.sh;
add openbox-mov-win-to-wrkspc.sh;
add openbox-nu-wrkspc.sh;
add tile-cur-wrkspc.sh;
update dmn-locker.sh, add tint2-bottom-upper-panel, change to throw error instead of install;
update README.md, add dmn-openbox-wrkspc.sh;
attempt 1 make lxde and openbox session work like i3 session, infinite workspace;
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
