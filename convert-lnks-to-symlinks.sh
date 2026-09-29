#!/bin/bash

mkdir -p symlinks

for l in *.lnk; do
    [ -e "$l" ] || continue
    t=$(tr -d '\r\n' < "$l")
    nt="${t//\~\//$HOME/}"
    n=$(basename "$l" .lnk)
    echo "Converting: $l -> symlinks/$n"
    ln -s "$nt" "symlinks/$n"
done

echo "Succes convert all lnks to symlinks."
