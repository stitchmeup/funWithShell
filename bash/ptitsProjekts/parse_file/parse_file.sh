#!/usr/bin/env sh

function backup {
    echo "$1"
}

pattern=""
while read -r hostname; do
    # On test si $hostname est vide ou non (permet d'éliminer de ligne vide qui casserai le motif)
    test -n "$hostname" && pattern="$pattern|$hostname"
done < "$1"
# On enlève le caractère "|" en trop au début
pattern=$(echo "$pattern" | cut -c 2-)

awk -v pattern="$pattern" '$0 ~ pattern { print $2 }' hosts | while read ip; do backup "$ip"; done
