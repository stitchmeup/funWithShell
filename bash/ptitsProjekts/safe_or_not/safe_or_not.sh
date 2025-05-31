#!/usr/bin/env bash

printf "\$1 : '%s'\n" "$1" 

# Example 1: Unsafe?
# Passed unsafe input directly into double quoted echo "" on printf line 1

echo "example 1:"

printf "some text printed between single quotes '%s'\n" "$(echo -n "$1" | base64 -w0 )"

# Example 2: Unsafe?
# Passed unsafe input directly into double quots echo "" on sanitized line 1

echo "example 2:"

sanitized=$(echo "$1" | sed 's/[$`\\]//g')
printf "sanitized : '%s'\n" "$sanitized'"
printf "some text printed between single quotes '%s'\n" "$(echo -n "$sanitized" | base64 -w0 )"

# Example 3: Safe?
# Replaced dangerous characters using sed before being passed into double quoted echo ""

echo "example 3:"

sanitized=$(sed 's/[$`\\]//g' <<< $1)
printf "sanitized : '%s'\n" "$sanitized'"
printf "some text printed between single quotes '%s'\n" "$(echo -n "$sanitized" | base64 -w0)"

