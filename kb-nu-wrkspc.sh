#!/bin/bash

# tot_wrkspc_cur=$(wmctrl -d | grep -c .)
tot_wrkspc_cur=$(wmctrl -d | wc -l)
# tot_wrkspc_cur=$(xdotool get_num_desktops)
echo "tot_wrkspc_cur: $tot_wrkspc_cur"

tot_wrkspc_nu=$((tot_wrkspc_cur + 1))
echo "tot_wrkspc_nu: $tot_wrkspc_nu"

wmctrl -n $tot_wrkspc_nu
# xdotool set_num_desktops $new_desktops
