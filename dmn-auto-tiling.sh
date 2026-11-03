#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    echo "[dmn-auto-tiling.sh] Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

kb=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --kb)
            kb="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

if [ -z "$kb" ]; then
    kb="ctrl+super+t"
fi

(
    xprop -root -spy _NET_CLIENT_LIST &
    xprop -root -spy _NET_CURRENT_DESKTOP &
    wait
) | while read -r line; do
    xdotool key "$kb"
done
