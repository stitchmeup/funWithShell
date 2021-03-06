#!/usr/bin/env bash

# failwith [-x STATUS] PRINTF-LIKE-ARGV
# Fail with the given diagnostic message
#
# The -x flag can be used to convey a custom exit status, instead of
# the value 1. A newline is automatically added to the output.

failwith()
{
  local OPTIND OPTION OPTARG status
  status=1
  OPTIND=1
  while getopts 'x:' OPTION; do
    case ${OPTION} in
      x) status="${OPTARG}";;
      ?) 1>&2 printf 'failwith: %s: Unsupported option.\n' "$1";;
    esac
  done
  shift $(( OPTIND - 1 ))
  {
    printf 'Failure: '
    printf "$@"
    printf '\n'
  } 1>&2
  exit "${status}"
}

failwith "$@"
