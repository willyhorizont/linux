#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
V="0.5.5" # ! DON'T FORGET TO CHANGE VERSION BEFORE RUNNING !!!! run git tag -d "$V" in case accidentally ran
T=$(date "+%d %b %Y @ %I:%M %p")
cd "$RD" || exit

H="
[Last updated: $T][version: $V]
"
H=$(sed -e '/./,$!d' <<< "$H")
# ! DON'T FORGET TO CHANGE COMMIT MESSAGE BEFORE RUNNING !!!!
M="
update indic0-wrkspc.sh, change to interval 0.5;
--touch tui0-tiling.sh or update kb-tile-cur-wrkspc.sh to select auto tiling variation if exist--;
update kb-tile-cur-wrkspc.sh to cycle tiles variation;
--remove cln-trl-wrkspc.sh and touch sld-wrkspc.sh to slide wrkspc to empty one--;
remove cln-trl-wrkspc.sh and add kb-cln-wrkspc.sh;
update dmn-wrkspc-mgr.sh, call kb-cln-wrkspc.sh;

canceled:
touch sv-tiling-geom-wrkspc-ls.sh to remember tiling geometry wrkspc_ls so kb-tile-cur-wrkspc.sh can run lighter;
update kb-tile-cur-wrkspc.sh, auto tile only when offset, is_tiled = not is_offset;
update kb-tile-cur-wrkspc.sh, auto tile only when geom is not LT, RT, etc;
maybe combine sv-tiling-geom-wrkspc-ls.sh with dmn-wrkspc-mgr.sh;
kill tux when tile keybind pressed;
kill tux when switching wrkspc;
keybind LT, RT, etc also modify conf;
update indic0-wrkspc.sh, change from read wmctrl -d intervally to read file written by every next prev wrkspc keybind press;
make decorator or wrapper higherorder function to auto place win to tile when opening app;
tinker about autotiling instead of manual auto tiling;
reason:
tried to kill tux when cur_wrkspc tiled but no way to track detached tiles, so tux might stays running when tiled;
tried to keep track geom tile in kb-tile-cur-wrkspc.sh but no way to track detached tiles;

TODO:
add abillity to navigate through tiles;
add abillity to move tile;
make window font size smaller;
check *openbox*.sh, remove openbox part if not related;
rename script to job*, kb*, wdgt*, to match indic*, tui*;
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
