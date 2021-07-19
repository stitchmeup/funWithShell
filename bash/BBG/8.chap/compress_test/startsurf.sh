#!/usr/bin/env bash

# This script provides an easy way for users to choose between browsers.

echo "These are the web browsers on this system:"

# Start here document
cat << BROWSERS
mozilla
links
lynx
konqueror
opera
netscape
BROWSERS
# End here document

echo -n "Which is your favorite? "

read browser

echo "Starting $browser, please wait..."
$browser &
