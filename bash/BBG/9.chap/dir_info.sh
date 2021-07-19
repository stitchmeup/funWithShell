#!/usr/bin/env bash

usage(){
    echo "./dir_info.sh DIRECTORY"
}
### ERROR ###
err(){
    echo "$1" >&2
    exit 1
}

### SANITY CHECKS ###
[ $# !=  1 ] && err "Too many or too low args..."
[ -d "$1" ] || err "$1 is not a directory!"

### MAIN ###
echo "Scanning $1 " 
echo
echo "5 Biggest files (including directories):"
du -h -d 1 "$1" | sort -rh | tail -n +2 | head -n 5
echo
echo "5 Last modified files (including directories):"
ls -ltau --color=none "$1" | tail +2 | awk '{ print $6,$7,$8,$9 }' | head -5
echo
echo "Done!"
