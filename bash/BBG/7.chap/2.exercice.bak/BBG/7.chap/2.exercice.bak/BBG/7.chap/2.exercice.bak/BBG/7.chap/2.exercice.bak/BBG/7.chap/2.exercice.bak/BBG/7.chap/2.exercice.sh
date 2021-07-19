#!/usr/bin/env bash

# Backup Script using public key to login into remote host via SSH

DIR_BACKUP="/home/mika/lab/bash/BBG"                            # Directory to backup ( recursively oc)
FILE_LOG="/home/mika/lab/bash/BBG/7.chap/2.exercice.log"        # File for log
DIR_DESTINATION="/home/mika/lab/bash/BBG/7.chap/2.exercice.bak" # Destination directory
REMOTE_SHELL="ssh"                                              # Remote Shell to use
USER="mika"                                                     # User name to login with remode shell
HOST="localhost"                                                # IP or hostname of host to connect with remote shell

rsync -av -i ssh $DIR_BACKUP $USER@$HOST:$DIR_DESTINATION &> $FILE_LOG
