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
V="0.7.0" # ! DON'T FORGET TO CHANGE VERSION BEFORE RUNNING !!!! run git tag -d "$V" in case accidentally ran
T=$(date "+%d %b %Y @ %I:%M %p")
cd "$RD" || exit

H="
[Last updated: $T][version: $V]
"
H=$(sed -e '/./,$!d' <<< "$H")
# ! DON'T FORGET TO CHANGE COMMIT MESSAGE BEFORE RUNNING !!!!
M="
combine indic* with tui* default to tui, --indicator for indic*;
add --pref --suff to --indicator *indctr;
rename indic0-wrkspc.sh                to wrkspc-indctr.sh;
rename indic0-screensavr.sh            to tux-indctr.sh;
combine indic1-bt.sh tui1-bt.sh        to bt.sh;
combine indic2-net.sh tui2-net.sh      to net.sh;
combine indic3-cam.sh tui3-cam.sh      to cam.sh;
combine indic4-mic.sh tui4-mic.sh      to mic.sh;
combine indic5-vol.sh tui5-vol.sh      to vol.sh;
rename indic6-powr.sh                  to powr-indctr.sh;
rename tui0-screensavr.sh              to screensavr-mgr.sh;
rename tui6-powr.sh                    to powr-mgr.sh;
rename tui6-1-powr-pfl.sh              to powr-pfl-mgr.sh;
rename tui6-2-brghtnss.sh              to scrn-brghtnss-mgr.sh;
rename tui6-3-blu-lght-fltr.sh         to blu-lght-fltr-mgr.sh;
rename tui6-4-bat-lenovo-thinkpad.sh   to bat-lenovo-thinkpad-mgr.sh;
rename tui0-powr-mnu-prompt.sh         to powr-mnu.sh;

working on:
add confirm-cmd.sh;
add --pango to --indicator *indctr;
add --pref --suff --pango to SPRM;
add --pref --suff --pango to SuckMyClock;
add rofi alt tab;
create tile-cur-win;

TODO #1:
update README.md, add strikethrough to wm that can not be installed via apt install;
TODO #2:
rofi grid;
mac launchpad;
skippy-xd;
mac mission control or windows task view;
remove space between months and days in SuckMyClock;
dvd screensaver;
panel with signal support, IPC?;
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
