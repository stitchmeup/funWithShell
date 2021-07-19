#!/usr/bin/env bash

# Count number of elements in a given directory
# Can count recursively

### INIT ###
declare -r myname='elmtInDirCounter'
declare -r myver='1.0'

usage() {
  echo ${myname}
  echo
  echo "Usage: ${myname} [-R] DIRECTORY [DIRECTORIES...]"
  echo
  echo "Options:"
  echo "  --version   show program's version number and exit"
  echo "  -h, --help  show this help message and exit"
  echo "  -R          count elmt recursively in subdirectories too"
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

# Allows hidden file to be expended by globbing
shopt -s dotglob
# Pattern that doesnt match anything are ignored
shopt -s nullglob

# Counts number of elements in a given dir
# Uses recursion
countInDir() {
  declare -i n=0
  for elmt in ${1}/*; do
    if [[ $2 ]] && [ -d "$elmt" ]; then
      n+=$(countInDir "$elmt" $2)
    fi
    ((n++))
  done
  echo $n
}

if [ $# -eq 0 ]; then
  err "Missing argument : a valid directory path must be given."
else
  if [[ ${1:0:2} = -- ]]; then
    option="${1:2}"
  elif [[ $1 =~ ^-[hvR]$ ]]; then
    option="${1:1}"
  fi
  case "${option}" in
    h|help) usage ;;
    version) version ;;
    R)
    if [[ $2 ]]; then
      recursion="true"
      shift
    else
      err "Missing argument : a valid directory path must be given."
    fi
    ;;
    *) [ -d "${1}" ] || err "Wrong argument : $1" ;;
  esac
fi

while [[ $1 ]]; do
  # Should be done before
  if [ -d ${1} ]; then
    echo "$1 : $(countInDir "$1" "$recursion")"
  else
    echo "$1 : Not a directory" >&2
  fi
  shift
done
