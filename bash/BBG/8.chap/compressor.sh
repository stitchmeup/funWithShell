#!/usr/bin/env bash

# This scripts takes one file as argument, ask you how you want to compress it and eventually does it. :)

FILE="$1"
if [[ ! -e "$FILE" ]]; then
    echo "Wrong file buddy!"
    exit 1
fi
FILE=$(echo "$FILE" | sed 's/\/$//') 

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
    gzip) tar -zcvf "${FILE}.tar.gz" "$FILE" ;;
    bzip2)tar -jcvf "${FILE}.tar.bz2" "$FILE" ;;
    compress) tar -Zcvf "${FILE}.tar.z" $FILE ;;
    zip) zip "${FILE}.zip" "$FILE" ;;
esac

echo "Done."
