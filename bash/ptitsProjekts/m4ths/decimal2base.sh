#!/usr/bin/env bash

### VARIABLE DECLARATION ###

declare -i NUMBER="$1"
declare -i BASE="$2"


### MAIN ###

declare -a dec_to_char

for i in {{0..9},{A..Z}}; do
    dec_to_char+=(${i})
done

declare -i remainder
declare -i quotient=$NUMBER

until [ $quotient == 0 ]; do
    remainder=$[${quotient}%${BASE}]
    total_b+=${dec_to_char[$remainder]}
    quotient=$[${quotient}/${BASE}]
done
echo "$total_b" | rev
