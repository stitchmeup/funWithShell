#!/usr/bin/env bash
# Change current dir to the directory where the script is stored
printf "Current dir: "
pwd
echo
echo "Changing dir..."
cd "$(dirname "$(readlink -f "$0")")"
echo
printf "Current dir: "
pwd
