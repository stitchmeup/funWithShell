#!/usr/bin/env bash

# Convert anybase <= 36 to decimal, with Horner's method
#
# Usage: base2decimal.sh NUMBER BASE

### VAR DECLARATION ###

declare -i BASE="$2"
NUMBER="$1"

### MAIN ###

# Associative array to associate 36 char to decimal value

declare -A char_to_dec
j=0
for i in {{0..9},{A..Z}}; do
    char_to_dec[${i}]=${j}
    ((j++))
done

# fold prints 1 char per line
# probably something more elegant to do here
declare -i total_b10=0
while read -r line; do
    total_b10=$[${total_b10}*${BASE}]+${char_to_dec[${line}]}
done < <(echo "$NUMBER" | fold -w1)       

echo $total_b10
