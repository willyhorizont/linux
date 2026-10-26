#!/bin/sh

TOOLTIP_TXT=$(cat << EOF
\`                              
       💡 indic0-screensavr.sh        
                                      
   click to open tui0-screensavr.sh   
                                     .
EOF
)

if pidof xpenguins > /dev/null; then
    echo ""
    printf "" 1>&2
else
    echo "🐧"
    printf "%s" "$TOOLTIP_TXT" 1>&2
fi
