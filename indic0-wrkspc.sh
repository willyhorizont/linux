#!/bin/bash

if ! command -v wmctrl &> /dev/null; then
    echo "Error: please install wmctrl."
    exit 1
fi

TOOLTIP_TXT=$(cat << EOF
\`                                 
       💡 indic0-wrkspc.sh         
                                   
  click to run cln-trl-wrkspc.sh   
                                  .
EOF
)

cur_wrkspc=$(wmctrl -d | grep '*' | cut -d' ' -f1)
tot_wrkspc=$(wmctrl -d | wc -l)
indic_output=""
for ((i=tot_wrkspc-1; i>=0; i--)); do
    if [ "$i" -eq "$cur_wrkspc" ]; then
        el="${i}*"
    else
        el="${i}"
    fi

    if [ -z "$indic_output" ]; then
        indic_output="$el"
    else
        indic_output="$indic_output | $el"
    fi
done
echo "$indic_output "
printf "%s" "$TOOLTIP_TXT" 1>&2
