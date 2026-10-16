#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
V="0.5.4" # ! DON'T FORGET TO CHANGE VERSION BEFORE RUNNING !!!! run git tag -d "$V" in case accidentally ran
T=$(date "+%d %b %Y @ %I:%M %p")
cd "$RD" || exit

H="
[Last updated: $T][version: $V]
"
H=$(sed -e '/./,$!d' <<< "$H")
# ! DON'T FORGET TO CHANGE COMMIT MESSAGE BEFORE RUNNING !!!!
M="
update dmn-locker, shorten condition logic, fix welcome-window idle-window detection;
update kb-nu-wrkspc.sh, make switch to nu-wrkspc after kb press;
touch kb-goto-wrkspc-prompt.sh;
update kb-mov-win-to-wrkspc-prompt.sh, change to rofi;
tried create is-tux-fit.sh box collision detection logic (Axis-Aligned Bounding Box) version but not working;
tried create is-tux-fit.sh Matrix 2D Screen version but not working;

TODO:
touch tui0-tiling.sh to select auto tiling variation;
make decorator or wrapper higherorder function to auto place win to tile;
add abillity to navigate through tiles;
add abillity to move tile;
touch sld-wrkspc.sh to slide wrkspc to empty one;
tinker about autotiling instead of manual auto tiling;
touch sv-tiling-geom-wrkspc-ls.sh to remember tiling geometry wrkspc_ls so tile-cur-wrkspc.sh can run lighter;
update tile-cur-wrkspc.sh, auto tile only when offset, is_tiled = not is_offset;
update tile-cur-wrkspc.sh, auto tile only when geom is not LT, RT, etc;
maybe combine sv-tiling-geom-wrkspc-ls.sh with dmn-openbox-wrkspc;
kill tux when tile keybind pressed;
kill tux when switching wrkspc;
keybind LT, RT, etc also modify conf;
make window font size smaller;
check *openbox*.sh, remove openbox part if not related;
rename script to job*, kb*, wdgt*, to match indic*, tui*;
remove separate config and move it to the code instead;
update indic0-wrkspc.sh, change from read wmctrl -d intervally to read file written by every next prev wrkspc keybind press;
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
