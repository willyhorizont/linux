#!/usr/bin/env bash

CORE_TEXT="SPACE AVAILABLE SPACE AVAILABLE "
CORE_LEN=${#CORE_TEXT}

POS=0
if read -r uptime_line < /proc/uptime; then
    SECONDS_INT="${uptime_line%%.*}"
    POS=$(( SECONDS_INT % CORE_LEN ))
fi

LONG_TXT="${CORE_TEXT}${CORE_TEXT}"

MOVING_PART="${LONG_TXT:$POS:32}"
RR="  ${MOVING_PART} "

printf "%s" "$RR"
