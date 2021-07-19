#!/usr/bin/env bash

for ((i = 0; i <= $#; i++)); do
    echo ${!i};
done
