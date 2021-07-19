#!/usr/bin/env bash

# This script tells you if you are old enough to drink alcohol or not.
# If so, you get to know how much beer you drank (low average ;) )

while [[ ! "$AGE" =~ [0-9]+ ]]; do
    read -p "How old are you, deer? " AGE
done

if [[ $AGE -ge 16 ]]; then
    echo "Make yourself at home, take a beer"
    Total_beer_drank=$(((${AGE}-16)*100))
    echo "You already drank $Total_beer_drank in your life, WTF MAN?!"
else
    echo "Sorry kiddo, you won't get any alcohol from me..."
    echo "Come back in $((16-$AGE)) year(s)!"
fi
