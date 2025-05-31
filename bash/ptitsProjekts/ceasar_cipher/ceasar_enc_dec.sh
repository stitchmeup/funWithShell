#!/usr/bin/env bash

# cypher or decypher Ceasar with key given as first param et encrypted text as second:
# cypher: ceasar_enc_dec.sh -enc KEYS ENCRYPTED_TEXT
# decypher: ceasar_enc_dec.sh -dec KEYS ENCRYPTED_TEXT

key="$2"
[[ "$1" == -dec ]] && key=$((26-$2))  
alpha+=$(echo {A..Z} | sed -r 's/ //g') 
cipher=$( echo $alpha | sed -r "s/^.{$key}//g")$(echo $alpha | sed -r "s/.{$( expr 26 - $key )}$//g")
echo "$3" | tr $alpha $cipher
