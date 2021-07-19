#!/usr/bin/env bash

searchPattern="$1"

curl -s "https://html.duckduckgo.com/html/?q=$searchPattern" | awk '/result__url/ {c+=1;getline;$1=$1;print}END{print c}'
