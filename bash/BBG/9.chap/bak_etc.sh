#!/usr/bin/env bash

DIR="/home/mika/lab/bash/BBG/9.chap/etc/"
BACKUP_DIR="/home/mika/lab/bash/BBG/9.chap/bak_etc/"

if [ -d ${BACKUP_DIR} ]; then
    echo "DELETING CURRENT BACKUP..."
    rm -r ${BACKUP_DIR}*
else 
    echo "CREATING BACKUP DIRECTORY..."
    mkdir ${BACKUP_DIR}
fi
echo "BACKUP STARTING..."
echo
for file in ${DIR}*; do
    cp -vau ${file} ${BACKUP_DIR}
done
echo
echo "DONE..."
echo
