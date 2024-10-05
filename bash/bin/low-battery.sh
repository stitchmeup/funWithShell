#!/usr/bin/env bash

# Set the following variables to your needs
# Path to the icon you want to display in the notification
icon="path_to_icon"
# User id to send the notification to
uid=1000
# Message to display in the notification
message="Plug me in! Pleeeaaase!"
# Battery level to trigger the notification in percent
limit="10"


subsystem="/sys/class/power_supply/BAT0"
bat_status=$(cat $subsystem/status)
bat_capacity=$(cat $subsystem/capacity)
 
if [ -z "$bat_capacity" ]; then
    exit 1
elif [ "$bat_status" != "Discharging" ]; then
    exit 0
elif [ "$bat_capacity" -le "$limit" ]; then
    DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${uid}/bus" notify-send -u critical -t 15000 -i "$icon" "$message"
fi
