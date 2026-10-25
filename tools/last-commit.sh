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
V="0.6.5" # ! DON'T FORGET TO CHANGE VERSION BEFORE RUNNING !!!! run git tag -d "$V" in case accidentally ran
T=$(date "+%d %b %Y @ %I:%M %p")
cd "$RD" || exit

H="
[Last updated: $T][version: $V]
"
H=$(sed -e '/./,$!d' <<< "$H")
# ! DON'T FORGET TO CHANGE COMMIT MESSAGE BEFORE RUNNING !!!!
M="
rename dmn-locker.sh to dmn-screensavr.sh;
update dmn-screensavr.sh, remove locking feature;
rename tui0-locker.sh to tui0-screensavr.sh;
update tui0-screensavr.sh, remove locking management;
--touch kb-cnfrm-cls.sh--;
--merge dmn-wrkspc-mgr.sh to indic0-wrkspc.sh, and delete dmn-wrkspc-mgr.sh--;
delete dmn-wrkspc-mgr.sh;
delete kb-cln-wrkspc.sh;
update and fix indic0-wrkspc.sh, make it only shows non empty ws;

TODO #1:
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
