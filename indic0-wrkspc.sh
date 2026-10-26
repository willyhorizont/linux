#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xprop &> /dev/null || ! command -v xdotool &> /dev/null; then
    echo "Error: missing dependencies 'wmctrl xprop xdotool'"
    exit 1
fi

SHOW_WINS=false
REVERSE_ORDER=false
USE_PANGO=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --shw-wins)
            SHOW_WINS=true
            shift
            ;;
        --rev)
            REVERSE_ORDER=true
            shift
            ;;
        --pango)
            USE_PANGO=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

TOOLTIP_TXT=$(cat << EOF
\`                                 
            💡 indic0-wrkspc.sh              
                                             
   click to open kb-goto-wrkspc-prompt.sh    
                                            .
EOF
)

printf "%s" "$TOOLTIP_TXT" 1>&2

handle_change() {
    cur_wrkspc=$(wmctrl -d | awk '{if ($2 == "*") print $1}')
    tot_wrkspc=$(wmctrl -d | grep -c .)
    OPEN_WINS_DATA=$(wmctrl -l -x -G 2>/dev/null | awk '{
        if ($7 == "pcmanfm.Pcmanfm" && $9 == "pcmanfm") next;
        if ($7 == "plank.Plank" && $9 == "plank") next;
        if ($7 == "tint2.Tint2") next;
        if ($7 == "xpenguins.Xpenguins") next;
        if ($7 ~ /welcome-window|idle-window/) next;
        print $2
    }')
    max_active_win_ws=-1
    if [ -n "$OPEN_WINS_DATA" ]; then
        max_active_win_ws=$(echo "$OPEN_WINS_DATA" | sort -nu | tail -n 1)
    fi
    if [ "$cur_wrkspc" -gt "$max_active_win_ws" ]; then
        max_valid_ws=$cur_wrkspc
    else
        max_valid_ws=$max_active_win_ws
    fi
    if [ "$max_valid_ws" -lt 0 ]; then
        max_valid_ws=0
    fi
    needed_tot_wrkspc=$((max_valid_ws + 1))
    if [ "$tot_wrkspc" -ne "$needed_tot_wrkspc" ]; then
        xdotool set_num_desktops "$needed_tot_wrkspc"
        tot_wrkspc="$needed_tot_wrkspc"
    fi
    indic_output=""
    if [ "$REVERSE_ORDER" = true ]; then
        start_loop=$((tot_wrkspc - 1))
        end_loop=0
        step=-1
    else
        start_loop=0
        end_loop=$((tot_wrkspc - 1))
        step=1
    fi
    for ((i=start_loop; step==1 ? i<=end_loop : i>=end_loop; i+=step)); do
        if [ "$SHOW_WINS" = true ]; then
            OPEN_WINS_COUNT=$(echo "$OPEN_WINS_DATA" | grep -c -w "$i")
        else
            if echo "$OPEN_WINS_DATA" | grep -q -w "$i"; then
                OPEN_WINS_COUNT=1
            else
                OPEN_WINS_COUNT=0
            fi
        fi
        if [ "$OPEN_WINS_COUNT" -eq 0 ] && [ "$i" -ne "$cur_wrkspc" ]; then
            continue
        fi
        display_i=$((i + 1))
        if [ "$SHOW_WINS" = true ]; then
            el="${OPEN_WINS_COUNT}wins@ws${display_i}"
        else
            el="${display_i}"
        fi
        if [ "$i" -eq "$cur_wrkspc" ]; then
            if [ "$USE_PANGO" = true ]; then
                el_styled="<span background='#00ADD8' foreground='#000000'> ${el} </span>"
            else
                el_styled="${el}*"
            fi
        else
            if [ "$USE_PANGO" = true ]; then
                el_styled="<span background='#000000' foreground='#CCFF00'> ${el} </span>"
            else
                el_styled="${el}"
            fi
        fi
        if [ -z "$indic_output" ]; then
            indic_output="$el_styled"
        else
            if [ "$USE_PANGO" = true ]; then
                sep_styled="<span background='#000000' foreground='#FF1493'>|</span>"
                indic_output="${indic_output}${sep_styled}${el_styled}"
            else
                indic_output="${indic_output} | ${el_styled}"
            fi
        fi
    done
    if [ "$USE_PANGO" = true ]; then
        echo "$indic_output"
    else
        echo "$indic_output "
    fi
}

handle_change

xprop -root -spy _NET_CURRENT_DESKTOP | while read -r _; do
    handle_change
done
