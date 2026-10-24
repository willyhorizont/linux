#!/bin/bash

awk '{
    secs = $1;
    hours = int(secs / 3600);
    minutes = int((secs % 3600) / 60);
    if (hours > 9999999999999) {
        hours = 9999999999999;
    }
    if (hours < 1000) {
        printf " uptime %3dhours %02dminutes |", hours, minutes;
    } else {
        printf " uptime %13dhours |", hours;
    }
}' /proc/uptime
