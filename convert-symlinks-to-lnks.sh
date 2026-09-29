#!/bin/bash

mkdir -p lnks

for l in *; do
    [ -L "$l" ] || continue
    t=$(readlink "$l")
    nt=$(echo "$t" | sed "s|$HOME/|~/|g")
    echo "Converting: $l -> lnks/${l}.lnk"
    echo "$nt" > "lnks/${l}.lnk"
done

echo "Succes convert all symlinks to lnks."
