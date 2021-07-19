#!/usr/bin/env bash

# String compile et exécute fichier.java

test -f "$1" && [[ "$1" =~ .:*.java ]] || exit 1

javac "$1" || exit

fileWithoutBase=${1/.java/}

java "$fileWithoutBase" || exit

# For franceIOI exercices
# Replace class name by "Main" and copy it to X clipboard 
sed -E '1,10s/(^class[[:space:]])[[:alpha:]]+/\1Main/' "$1" | sed -E 's/java\.util\.Scanner/algorea.Scanner/' | xclip -i -selection clipboard
