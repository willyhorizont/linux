#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")

gcc -O2 $RD/SPRM.c -o $RD/SPRM-c
gcc -O2 $RD/SuckMyClock.c -o $RD/SuckMyClock-c
gcc -O2 $RD/uptime.c -o $RD/uptime-c

g++ -O3 $RD/SPRM.cpp -o $RD/SPRM-cpp
g++ -O3 $RD/SuckMyClock.cpp -o $RD/SuckMyClock-cpp
g++ -O3 $RD/uptime.cpp -o $RD/uptime-cpp
