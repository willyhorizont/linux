#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
V="0.5.0" # ! DON'T FORGET TO CHANGE VERSION BEFORE RUNNING !!!! run git tag -d "$V" in case accidentally ran
T=$(date "+%d %b %Y @ %I:%M %p")
cd "$RD" || exit

H="
[Last updated: $T][version: $V]
"
H=$(sed -e '/./,$!d' <<< "$H")
# ! DON'T FORGET TO CHANGE COMMIT MESSAGE BEFORE RUNNING !!!!
M="
done with i3, openbox is satisfying;
finish make lxde and openbox session work like i3 session, infinite workspace with manual auto tiling;
add get-opn-win-ls.sh;
finish tile-cur-wrkspc.sh;



TODO:
touch tui0-tiling.sh to select auto tiling variation;
touch goto-wrkspc.sh;
touch sv-tiling-geom-wrkspc-ls.sh to remember tiling geometry wrkspc_ls so tile-cur-wrkspc.sh can run lighter;
tinker about autotiling instead of manual auto tiling;
maybe combine sv-tiling-geom-wrkspc-ls.sh with dmn-openbox-wrkspc;
check openbox*.sh, remove openbox part if not related;
rename script to job*, kb*, prompt*, wdgt*, to match indic*, tui*;
remove separate config and move it to the code instead;
update indic0-wrkspc.sh, change from read wmctrl -d intervally to read file written by every next prev wrkspc keybind press;
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
