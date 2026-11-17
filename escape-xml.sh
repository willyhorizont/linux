#!/bin/sh

if [ $# -gt 0 ]; then
    printf '%s' "$*" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
else
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
fi
