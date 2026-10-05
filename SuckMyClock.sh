#!/bin/sh

MONTH_NUM=$(date +"%m")
DAY_NUM=$(date +"%d")
YEAR=$(date +"%Y")
MONTH_INT=$(date +"%m" | sed 's/^0//')

TOTAL_DAYS=$(date -d "$YEAR-$((MONTH_INT+1))-01 -1 day" +"%d" 2>/dev/null || date -d "$YEAR-$MONTH_NUM-01 +1 month -1 day" +"%d")

DATE_STRING=$(date +"%a, %d %b %Y")
TIME_24=$(date +"%H:%M:%S")
TIME_12=$(date +"%I:%M:%S %p")


echo -n "| ${MONTH_NUM}/12 months | ${DAY_NUM}/${TOTAL_DAYS} days | ${DATE_STRING} | ${TIME_24} | ${TIME_12} "

cat << EOF 1>&2
\`                         
        SuckMyClock        
     * Shell version *     
                           
  click to open calcurse   
                           
                          .
EOF
