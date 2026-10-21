#!/bin/bash

if ! command -v wmctrl &> /dev/null; then
    echo "Error: please install wmctrl."
    exit 1
fi

TOOLTIP_TXT=$(cat << EOF
\`                                 
       💡 indic0-wrkspc.sh         
                                   
  click to run kb-cln-wrkspc.sh   
                                  .
EOF
)

printf "%s" "$TOOLTIP_TXT" 1>&2

while true; do
    cur_wrkspc=$(wmctrl -d | grep '*' | awk '{print $1}')
    tot_wrkspc=$(wmctrl -d | wc -l)
    indic_output=""
    for ((i=tot_wrkspc-1; i>=0; i--)); do
        OPEN_WINS_COUNT=$(wmctrl -l -x -G | awk -v ws="$i" '$2 == ws {
            if ($7 == "pcmanfm.Pcmanfm" && $9 == "pcmanfm") next;
            if ($7 == "plank.Plank" && $9 == "plank") next;
            if ($7 == "tint2.Tint2") next;
            if ($7 == "xpenguins.Xpenguins") next;
            if ($7 ~ /welcome-window|idle-window/) next;
            print $1
        }' 2>/dev/null | grep -c .)
        if [ "$i" -eq "$cur_wrkspc" ]; then
            el="${OPEN_WINS_COUNT}wins@ws${i}*"
        else
            el="${OPEN_WINS_COUNT}wins@ws${i}"
        fi
        if [ -z "$indic_output" ]; then
            indic_output="$el"
        else
            indic_output="$indic_output | $el"
        fi
    done
    echo "$indic_output "
    sleep 0.2
done
