#!/bin/bash

url_ics='https://calendar.google.com/calendar/ical/id.indonesian%23holiday%40group.v.calendar.google.com/public/basic.ics'

curl -s "$url_ics" | awk '
    BEGIN {RS="BEGIN:VEVENT"; ORS=""} 
    NR==1 {print $0; next} 
    /SUMMARY:.*(Diwali|Malam Natal|1 Ramadan|Malam Tahun Baru)/ {next} 
    {print "BEGIN:VEVENT" $0}
' > "$HOME/willyhorizont.github.io/indonesian-holiday.ics"

calcurse -P
calcurse -i "$HOME/willyhorizont.github.io/indonesian-holiday.ics"
