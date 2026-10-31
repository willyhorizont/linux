#!/bin/bash

xprop -root -spy _NET_CLIENT_LIST | while read -r line; do
    notify-send "window count changed!"
done
