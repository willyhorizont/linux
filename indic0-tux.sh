#!/bin/sh

TOOLTIP_TXT=$(cat << EOF
\`                              
      💡 indic0-tux.sh          
                                
    click to open tui0-tux.sh   
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
