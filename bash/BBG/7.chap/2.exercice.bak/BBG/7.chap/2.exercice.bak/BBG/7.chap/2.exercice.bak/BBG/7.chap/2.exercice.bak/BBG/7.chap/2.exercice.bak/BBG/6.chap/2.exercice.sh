#!/usr/bin/env bash

du -sh /* 2> /dev/null |\
    sort -rhk 1 | head -3 |\
    sed 's/\///' |\
    awk 'BEGIN {print "*** Top 3 users of disk space ***"}\
    {print NR ": User: " $2 " with " $1 }'
