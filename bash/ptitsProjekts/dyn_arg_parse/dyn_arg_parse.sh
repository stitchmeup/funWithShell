#!/usr/bin/env bash
###
# USAGE : easy_way.sh "FILE" "N ITERATION"
# A executer dans un dossier contenant uniquement le fichier pdf
# (et surtout pas de sous-dossier)
###

test -f "$1" || exit 1
if ! [[ "$2" =~ ^[0-9]+$ ]]; then
  exit 1
fi

cp "$1" "./res_file"
file="./res_file"
dir="./_res_file.extracted"

for ((i = 1; i <= "$2"; i++)); do
  printf %s.. "$i"
  binwalk -q --include="zlib" --count=1 --offset=106 -e "$file"
  mv "${dir}/6A" "$file"
  rm -r "$dir"
  # On sait que le fihcier s'appellera 6A.
done
echo
