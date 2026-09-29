#!/bin/bash

symls=""

for l in *; do
    [ -L "$l" ] || continue
    t=$(readlink "$l")
    nt=$(echo "$t" | sed "s|$HOME/|~/|g")
    symls="${symls}${l};${nt}\n"
done

echo -e -n "$symls" > symlinks.txt
