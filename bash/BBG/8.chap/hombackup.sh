#!/usr/bin/env bash

# Automatic backup with tar (using cvp arg):
# - Check space left and needed
# - Incremental or full backup
# - keeps user updated

# No usage, no err ;)


# Test args: no args or exit

if [[ $# -gt 0 ]]; then
    echo "Error: No args should be given"
    exit 1
fi


### Variables Declarations ###

DIR="/home/mika/lab/bash/BBG/"
TAR_FILE="/home/mika/lab/bash/dump/homebackup.tar"
TAR_DB="/home/mika/lab/bash/dump/homebackup.db"
DATE_FILE="/home/mika/lab/bash/dump/homebackup.date"
PARTITION="/home"


### Functions ###

bytes_to_mega(){
    if [[ $1 -lt 1000 ]]; then
        SIZE="$1 bytes"
    else
        SIZE="$(($1/1024))M"
    fi
    echo "$SIZE"
}



### SPACE CHECK ###

SPACE_LEFT=$(df -Hk "$PARTITION" | tail -1 | awk '{ print $4 }')
SPACE_NEEDED=$(du -sk "$DIR" | awk '{ print $1 }')


SPACE_LEFT_HUMAN=$(bytes_to_mega ${SPACE_LEFT})
SPACE_NEEDED_HUMAN=$(bytes_to_mega ${SPACE_NEEDED})

if [[ $SPACE_LEFT -lt $SPACE_NEEDED ]]; then
    echo "Error: Not enough space available"
    echo "Space needed:  ${SPACE_NEEDED_HUMAN}" 
    echo "Space left: ${SPACE_LEFT_HUMAN}"     
    exit 1
fi


### DATE CHECK ###

[[ -f ${TAR_FILE} ]] && [[ ${DATE_FILE} ]] &&  LAST_MODIF_DATE=$(date -r ${DATE_FILE} +%s)
a_week_ago=$(($(date +%s)-(3600*24*7)))


### FULL OR INCRE ###

if ([[ $LAST_MODIF_DATE -lt $a_week_ago ]] || [[ ! -f ${TAR_FILE} ]]); then
    answer="f"
fi

while [[ ! "$answer" =~ [f|i] ]]; do
    read -p "Would you like to do a full backup or an incremental one? [f=full/i=incremental] > "  answer
done


if [[ $answer == "f" ]]; then
    [[ -f $TAR_FILE ]] && ( mv $TAR_FILE "${TAR_FILE}.bak"; mv $TAR_DB "${TAR_DB}.bak"; touch ${DATE_FILE} )
    echo
    echo "A new full Archive is going to be created." 
    sleep 3
fi

### Archive creation ###

echo "Starting archive..."
echo "Information:"
echo -e "\tarchive file: ${TAR_FILE}"
echo -e "\tdb file for incremental: ${TAR_DB}"
echo "Creating archive..."

tar -cp --listed-incremental=${TAR_DB} --file=${TAR_FILE} $DIR

echo 
echo "DONE!"
