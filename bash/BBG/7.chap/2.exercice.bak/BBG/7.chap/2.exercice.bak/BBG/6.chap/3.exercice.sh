#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "ERROR, file not found"
    echo "Syntax is: 3.exercice.sh <file>"
    exit
fi
sed 's/ /\t/' $1 | awk -f "3.exercice.awk"
