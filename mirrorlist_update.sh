#!/bin/bash

# Modifying mirrors used by pacman, using rankmirrors to rank top 6 (by speed).
# Using mirrorlist.pacnew file and French mirrors by default
# Can fetch list of mirrors (see url variable below) and specify another country

if (( $EUID != 0 )); then
    echo "Operation not permitted"
    exit 1
fi

Usage(){
    echo "Usage: mirrorlist [OPTIONS [ARG]]"
    echo "--help, -h:   show this help message and exit"
    echo "-wget:        fetch mirror list from https://www.archlinux.org/mirrorlist/\${custom_url}"
    echo "For more information about the script, read the script itself: $(readlink -f "$0")"
}
    
path_to_dir="/etc/pacman.d/"                # Path to mirrorlist directory
file_mirror="${path_to_dir}mirrorlist.bak"  # Mirrors'list before ranking
custom_url="https://archlinux.org/mirrorlist/?country=AT&country=BE&country=HR&country=CZ&country=DK&country=FI&country=FR&country=DE&country=GR&country=HU&country=IS&country=IE&country=IT&country=LU&country=MC&country=NL&country=PT&country=RS&country=SI&country=ES&country=SE&country=CH&protocol=https&ip_version=4" # Default URL from which to get mirrors list


# Getting mirrors'list depending on arguments.
get_mirrorlist(){
    case "$1" in
        --help|-h)
            Usage
            exit 0
            ;;
        -wget)
            wget -O "$file_mirror" "$custom_url" 2> /dev/null
            ;;
        *)  echo "Error: wrong args."
            Usage
            exit 1
            ;;
    esac
}

## Check if file_mirror exists if not creates it.
[[ -f "$file_mirror" ]] || touch "$file_mirror" 

while [[ $1 ]]; do
    get_mirrorlist "$1"
done


echo "Work in progress..."
sed -i "s/^#Server/Server/g" "$file_mirror"
rankmirrors -n 6 "$file_mirror" > "${path_to_dir}mirrorlist" || exit 1
echo "Mirrors ranked!"
echo
echo "Printing mirrorlist in use:"
echo
cat "${path_to_dir}mirrorlist"
echo
echo "exiting..."
