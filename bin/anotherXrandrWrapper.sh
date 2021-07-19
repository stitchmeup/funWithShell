#!/usr/bin/env bash

#   Another auto Xrandr configuration script
#
#   USAGE: anotherAutoXrandr [-m|--monitor xrandr_output_name [-p|--posistion right]] [-v|--verbose] [-h|--help]
#   to list xrandr output name run xrandr --listactivemonitors
#
#   REQUIRES xrandr (xorg-xrandr on ArchLinux)
#
#   Allow i3 to be used with multiple joined monitor

### INIT ###
declare -r myname='i3_multiple_monitor'
declare -r myver='1.0'

usage() {
    echo "${myname} v${myver}"
    echo
    echo "i3_multiple_monitor allows i3 workspace to be spanned accrossed multiple monitors"
    echo
    echo "Usage: ${myname} [options]"
    echo
    echo "Options:"
    echo "  --version           show program's version number and exit"
    echo "  -h, --help          show this help message and exit"
    echo "  -p, --position      determine relative position of the monitor to be added compared to the position of the primary monitor"
    echo "                      position must be left or right, default is left"
    echo "  -m, --monitor       name of the monitor to be manipulated with xrandr"
    echo "                      all name of active monitors can be obtained with the command xrandr --listactivemonitors"
    echo "  -d, --default       Set default settings by running: xrandr --auto"
    exit 0
}

version() {
    echo "${myname} ${myver}"
    exit 0
}

err() {
    echo "$1" >&2
    exit 1
}

# Default position
pos="left"

# Default monitor 
# We have to parse xrandr output because monitor name are not predictable (can be modified by GPU's drivers installions/settings).
readarray monitor < <(xrandr | awk '{ if ($0 ~ /\<connected\>/) { print $1 } }')

### ARG PARSING ###
while [[ $1 ]]; do
    if [[ ${1:0:2} = -- ]]; then
        option="${1:2}"
    elif [[ $1 =~ ^-[hpmd]$ ]]; then
        option="${1:1}"
    fi
    case "${option}" in
        h|help) usage ;;
        version) version ;;
        p|position)
            [[ $2 ]] || err "Must specify a position."
            [[ $2 = right || $2 = left ]] || err "$2 is an unvalid position."
            pos="$2"
            shift 2 ;;
        m|monitor)
            [[ $2 ]] || err "Must specify a monitor."
            { [[ "$2" == "${monitor[1]}" ]] || [[ "$2" == "${monitor[0]}" ]]; } &&  monitor[1]="$2" || err "$2 : monitor not connected."
            shift 2 ;;
        *) err "'$1' is an invalid argument." ;;
    esac
done

### EXEC ###
# sometimes, we have to launch xrandr before to make following command work
xrandr 1>/dev/null 2>&1
if [[ ${monitor[1]} ]]; then
    xrandr --output ${monitor[1]} --${pos}-of ${monitor[0]} --auto
else
    xrandr --auto
fi
