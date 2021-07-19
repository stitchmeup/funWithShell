#!/usr/bin/env bash

# This script gives information about a file.

if [[ "$1" ]]; then
    FILENAME="$1"
else
    read -p "File name: " FILENAME
fi

echo "Properties for $FILENAME:"

if [ -f $FILENAME ]; then
  echo "Size is $(ls -lh $FILENAME | awk '{ print $5 }')"
  echo "Type is $(file $FILENAME | cut -d":" -f2 -)"
  echo "Inode number is $(ls -i $FILENAME | cut -d" " -f1 -)"
  echo "$(df -h $FILENAME | grep -v Mounted | awk '{ print "On",$1", \
which is mounted as the",$6,"partition."}')"
else
  echo "File does not exist."
fi
