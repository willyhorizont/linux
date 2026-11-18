#!/bin/sh

if ! command -v xdotool >/dev/null 2>&1; then
    notify-send "close-active-window.sh" "Error: missing dependencies 'xdotool'..."
    exit 1
fi

$HOME/willyhorizont.github.io/linux/confirm-cmd.sh || exit 1

xdotool getactivewindow windowclose
