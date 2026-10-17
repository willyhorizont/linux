#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    notify-send "kb-cln-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

cur_wrkspc=$(wmctrl -d | grep '*' | cut -d' ' -f1)
tot_wrkspc=$(wmctrl -d | wc -l)
actv_wins_wrkspcs=$(wmctrl -l -x | awk '$2 ~ /^[0-9]+$/ {
    if ($7 == "pcmanfm.Pcmanfm" && $9 == "pcmanfm") next;
    if ($7 == "plank.Plank" && $9 == "plank") next;
    if ($7 == "tint2.Tint2") next;
    if ($7 == "xpenguins.Xpenguins") next;
    if ($7 ~ /welcome-window|idle-window/) next;
    print $2
}' | sort -n -u)

if [ -z "$actv_wins_wrkspcs" ]; then
    xdotool set_desktop 0
    xdotool set_num_desktops 1
    exit 0
fi

if ! echo "$actv_wins_wrkspcs" | grep -q "^${cur_wrkspc}$"; then
    saved_wrkspc_ls=$(echo -e "${actv_wins_wrkspcs}\n${cur_wrkspc}" | sort -n -u)
else
    saved_wrkspc_ls="$actv_wins_wrkspcs"
fi

read -r -a valuable_arr <<< "$(echo "$saved_wrkspc_ls" | tr '\n' ' ')"

new_slot_i=0
new_wrkspc=0
for old_ws in "${valuable_arr[@]}"; do
    if [ "$old_ws" -eq "$cur_wrkspc" ]; then
        new_wrkspc=$new_slot_i
    fi
    wins_in_old_ws=$(wmctrl -l -x | awk -v ws="$old_ws" '$2 == ws {
        if ($7 == "pcmanfm.Pcmanfm" && $9 == "pcmanfm") next;
        if ($7 == "plank.Plank" && $9 == "plank") next;
        if ($7 == "tint2.Tint2") next;
        if ($7 == "xpenguins.Xpenguins") next;
        if ($7 ~ /welcome-window|idle-window/) next;
        print $1
    }' 2>/dev/null)
    if [ -n "$wins_in_old_ws" ]; then
        if [ "$old_ws" -ne "$new_slot_i" ]; then
            for wid in $wins_in_old_ws; do
                wmctrl -i -r "$wid" -t "$new_slot_i"
            done
        fi
    fi
    new_slot_i=$(( new_slot_i + 1 ))
done
xdotool set_desktop "$new_wrkspc"
if [ "$new_slot_i" -gt 0 ]; then
    xdotool set_num_desktops "$new_slot_i"
fi
