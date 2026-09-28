#!/bin/sh

if pidof xpenguins > /dev/null; then
    echo ""
else
    echo "🐧"
fi
