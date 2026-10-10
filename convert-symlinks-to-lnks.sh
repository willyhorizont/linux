#!/bin/bash

mkdir -p lnks

rsltstr=""
for l in *; do
    [ -L "$l" ] || continue
    t=$(readlink "$l")
    nt=$(echo "$t" | sed "s|$HOME/|~/|g")
    echo "Converting: $l -> lnks/${l}.lnk"
    echo "$nt" > "lnks/${l}.lnk"
    rsltstr+="${l};${nt}\n"
done
echo -e "$rsltstr" > lnks/all-lnks.txt

echo "Succes convert all symlinks to lnks."
