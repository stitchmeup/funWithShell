#!/usr/bin/env bash

while [[ ! $break =~ ^break$ ]]; do
    read -p "Shall I [break] out of it? " break
    echo $break
done
