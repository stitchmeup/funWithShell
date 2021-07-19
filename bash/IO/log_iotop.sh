#!/usr/bin/env bash

# Logs iotop output for debug purposes

logfile="/home/mika/lab/IO/iotop.log"
errorfile="/home/mika/lab/IO/iotop.error"

trap "{ echo -e \"\n$(date):STOP\" | tee -a >&2; exec 1>&-; exec 2>&-; }" EXIT TERM 

exec 1> "$logfile"
exec 2> "$errorfile"

echo -e "\n$(date):START" | tee -a >&2

sudo iotop -b -d 0.2 -o -t -qqq | sed  -u "/iotop/d"

exit
