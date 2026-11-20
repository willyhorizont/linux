#!/bin/bash

printf "%s[%s]\n" "$(LC_TIME=C date '+%a-%d-%b-%Y|%I:%M:%S%p')" "$*" >> "$HOME/willyhorizont.github.io/log.txt"
