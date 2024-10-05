#!/usr/bin/env bash

#   Update mirrorlist used by pacman
#
#   USAGE: script.sh [-h|-v] OPTIONS ...
#
#   REQUIRES: pacman-contrib (for rankmirrors script)
#
#   DESCRIPTION: Update mirrorlist used by pacman and rank mirrors servers by speed.

### INIT ###
declare -r myname="$0"
declare -r myver='0.1'

usage() {
    echo "${myname} v${myver}"
    echo
    echo "Update mirrorlist used by pacman and rank mirrors servers by speed."
    echo
    echo "Usage: ${myname} [options]"
    echo
    echo "Options:"
    echo "  --version           show program's version number and exit"
    echo "  -h, --help          show this help message and exit"
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

### ARG PARSING ###
while [[ $1 ]]; do
    if [[ ${1:0:2} = -- ]]; then
        option="${1:2}"
    elif [[ $1 =~ ^-[ha]$ ]]; then
        option="${1:1}"
    fi
    case "${option}" in
        h|help) usage ;;
        version) version ;;
        *) err "'$1' is an invalid argument." ;;
    esac
done

### VARIABLES DECLARATION ###
declare -r mirrorlist_dir='/etc/pacman.d'
declare -r mirrorlist="${mirrorlist_dir}/mirrorlist"
declare -r mirrorlist_backup="${mirrorlist_dir}/mirrorlist.bak"
declare -r mirrorlist_custom="/tmp/mirrorlist.custom"
declare -r mirrorlist_tmp="/tmp/mirrorlist.tmp"
declare -r default_url="https://archlinux.org/mirrorlist/?country=AT&country=BE&country=DK&country=FR&country=DE&country=IS&country=IT&country=LU&country=NL&country=PT&country=ES&country=SE&country=CH&protocol=https&ip_version=4&ip_version=6&use_mirror_status=on"

### SANITY CHECKS ###
[[ -f "${mirrorlist}" ]] || err "File '${mirrorlist}' not found."

### EXEC ###
echo "Starting update of mirrorlist..."
echo "Backing up current mirrorlist..."
sudo cp "${mirrorlist}" "${mirrorlist_backup}"
echo "Downloading new mirrorlist..."
curl -s "${default_url}" | sed 's/^#Server/Server/' > "${mirrorlist_custom}"
echo "Ranking mirrors..."
rankmirrors -n 6 "${mirrorlist_custom}" > "${mirrorlist_tmp}"
sudo cp "${mirrorlist_tmp}" "${mirrorlist}"
echo "Mirrorlist ranked."
echo "Testing new mirrorlist..."
sudo pacman -Syu
echo "Mirrorlist updated."

exit 0