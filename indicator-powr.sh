#!/bin/bash

echo "AC=? BAT=?      | "

if [ ! -d /sys/class/power_supply ] || [ -z "$(ls /sys/class/power_supply/ | grep -E '^BAT|^battery')" ]; then
    echo "AC=Y BAT=N      | "
    exit 0
fi

ACPI_OUT=$(acpi -b 2>/dev/null | head -n1)
CAP=$(echo "$ACPI_OUT" | awk -F', ' '{print $2}' | tr -d '% ')
CAP_PAD=$(printf "%3d" "${CAP:-0}")

if [[ "$ACPI_OUT" =~ "Charging" ]]; then
    echo "AC=Y BAT=Y $CAP_PAD% | "
else
    if [ -f /sys/class/power_supply/AC/online ] && [ "$(cat /sys/class/power_supply/AC/online)" = "1" ]; then
        echo "AC=Y BAT=Y $CAP_PAD% | "
    else
        echo "AC=N BAT=Y $CAP_PAD% | "
    fi
fi
