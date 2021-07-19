#!/usr/bin/env bash

# This scripts takes one file as argument, ask you how you want to compress it and eventually does it. :)

FILE="$1"
if [[ ! -e "$FILE" ]]; then
    echo "Wrong file buddy!"
    exit 1
fi

echo "This are the compress methods available: "
cat << METHODS
gzip
bzip2
compress
zip
METHODS

while [[ ! "$METHOD" =~ gzip|bzip2|compress|zip ]]; do
    read -p "Chose you compress method: " METHOD
done

echo "Compressing..."

case $METHOD in
    gzip) tar -zcvf "$FILE" ;;
    bzip2)tar -jcvf "$FILE" ;;
    compress) tar -Zcvf "$FILE" ;;
    zip) zip $FILE ;;
esac

echo "Done."
