#!/usr/bin/env bash

# Convert anybase <= 36 to decimal
#
# Usage: base2decimal.sh NUMBER BASE

### VAR DECLARATION ###

declare -i BASE="$2"

declare -i base_power=1


### MAIN ###

# Associative array to associate 36 char to decimal value

declare -A char_to_dec
j=0
for i in {{0..9},{A..Z}}; do
    char_to_dec[${i}]=${j}
    ((j++))
done

# rev reverses string, fold prints 1 char per line
while read -r line; do
    declare -i value_b10=$[${char_to_dec[${line}]}*${base_power}]
    declare -i total_b10+=${value_b10}
    base_power=$[${base_power}*${BASE}]
done < <(echo "$1" | rev | fold -w1)       

echo $total_b10
