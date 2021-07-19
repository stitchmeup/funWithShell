#!/usr/bin/env bash

# This script converts all file names containing upper case characters into file# names containing only lower cases.


for name in ${1}*; do

if [[ "$name" != *[[:upper:]]* ]]; then
continue
fi

ORIG="$name"
NEW=$(echo $name | tr 'A-Z' 'a-z')

if [[ -a "$NEW" ]]; then
    continue
fi

mv "$ORIG" "$NEW"
echo "new name for $ORIG is $NEW"
done
