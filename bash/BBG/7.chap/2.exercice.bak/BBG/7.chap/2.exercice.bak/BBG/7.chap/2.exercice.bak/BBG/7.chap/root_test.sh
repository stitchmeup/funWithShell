#!/usr/bin/env bash
test "$(whoami)" != 'root' && (echo "you aint root"; exit 1)
test "$?" -eq 0 || exit
echo "Bypass"
