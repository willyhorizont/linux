#!/bin/bash

STATUS_FILE="/sys/class/video4linux/video0/device/power/runtime_status"

if [ -f "$STATUS_FILE" ]; then
    read -r STATUS < "$STATUS_FILE"
    if [ "$STATUS" = "active" ]; then
        echo "cam=Y | "
    else
        echo "cam=N | "
    fi
else
    echo "cam=N | "
fi
