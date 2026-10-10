#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
rm -rf "$HOME/willyhorizont.github.io/linux"
mkdir -p "$HOME/willyhorizont.github.io/linux/"
cp -r "$RD/." "$HOME/willyhorizont.github.io/linux/"
clear
