#!/usr/bin/env bash

#   TEMPLATE FOR BASH SCRIPTS
#
#   USAGE: script.sh [-h|-v] OPTIONS ...
#
#   REQUIRES: softwares
#
#   DESCRIPTION: long description if required

### INIT ###
declare -r myname='script'
declare -r myver='0.1'

usage() {
    echo "${myname} v${myver}"
    echo
    echo "template for bash scripts"
    echo
    echo "Usage: ${myname} [options]"
    echo
    echo "Options:"
    echo "  --version           show program's version number and exit"
    echo "  -h, --help          show this help message and exit"
    echo "  -a, --another FOO   antoher parameters taking FOO as args"
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
        a|another)
            [[ $2 ]] || err "Missing args."
            shift 2 ;;
        *) err "'$1' is an invalid argument." ;;
    esac
done

### EXEC ###
echo "DOING SOMETHING..."
sleep 1
echo "DONE"
