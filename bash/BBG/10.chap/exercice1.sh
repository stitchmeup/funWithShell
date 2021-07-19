#!/usr/bin/env bash

# Display the name of the script being executed
echo "script name: $0"

echo

# Display total number of args passed to the script
echo "number of args: $#"

echo

# Display the first, third and tenth argument given to the script
for arg_pos in {1..10}; do
    args_array["$arg_pos"]="$1"
    shift
done
echo -e "first arg: ${args_array[1]}\n\
third arg: ${args_array[2]}\n\
tenth arg: ${args_array[10]}"

echo
