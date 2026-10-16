#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
V="0.5.2" # ! DON'T FORGET TO CHANGE VERSION BEFORE RUNNING !!!! run git tag -d "$V" in case accidentally ran
T=$(date "+%d %b %Y @ %I:%M %p")
cd "$RD" || exit

H="
[Last updated: $T][version: $V]
"
H=$(sed -e '/./,$!d' <<< "$H")
# ! DON'T FORGET TO CHANGE COMMIT MESSAGE BEFORE RUNNING !!!!
M="
update purgex command;
add run-session.sh;
update tile-cur-wrkspc.sh, change CF to F;
update debian-apt.md, add system install age, add apt install history log location, add apt install history log, add Check is any depends on;
update general.md, add Check if something is installed;
update cool-package.csv, add top, htop, nmon, glances, gtop;


TODO:
touch tui0-tiling.sh to select auto tiling variation;
touch goto-wrkspc.sh;
touch sv-tiling-geom-wrkspc-ls.sh to remember tiling geometry wrkspc_ls so tile-cur-wrkspc.sh can run lighter;
touch sv-cur-ses.sh, to save current session;
touch opn-lst-ses.sh, to open last session;
touch run-session.sh, to run sequence opening apps to spesific wrkspc and tile keybind;
make decorator or wrapper higherorder function to auto place win to tile;
add abillity to navigate through tiles;
touch sld-wrkspc.sh to slide wrkspc to empty one;
tinker about autotiling instead of manual auto tiling;
auto tile only when offset, is_tiled = not is_offset;
auto tile only when geom is not LT, RT, etc;
kill tux when tile keybind pressed;
kill tux when switching wrkspc;
keybind LT, RT, etc also modify conf;
make window font size smaller;
maybe combine sv-tiling-geom-wrkspc-ls.sh with dmn-openbox-wrkspc;
check openbox*.sh, remove openbox part if not related;
rename script to job*, kb*, prompt*, wdgt*, to match indic*, tui*;
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
git push origin main --force
git push origin --tags --force
