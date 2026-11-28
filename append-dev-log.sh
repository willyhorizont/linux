#!/bin/bash

printf "%s[%s]\n" "$(LC_TIME=C date '+%a-%d-%b-%Y|%I:%M:%S%p')" "$*" >> "$HOME/willyhorizont.github.io/log.txt"

# usage: "$HOME/willyhorizont.github.io/linux/append-dev-log.sh" "test"
