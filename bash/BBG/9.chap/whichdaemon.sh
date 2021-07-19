#!/usr/bin/env bash

daemons_list=("apache2" "sshd" "ntpd")
other_list=("User choice" "QUIT")
full_list=("${daemons_list[@]}" "${other_list[@]}")
echo "${full_list[@]}"

is_running(){
    if  ps -C "$1" &> /dev/null ; then
        echo "$1 is running"
    else
        echo "$1 not running"
    fi
}

select DAEMON in "${full_list[@]}"; do
    case $DAEMON in
        "${daemons_list[@]}")
            is_running "$DAEMON"
            ;;
        "User choice")
            read -r -p "What daemons do you wanna check? " CHOICE
            is_running "$CHOICE"
            ;;
        "QUIT")
            break
            ;;
    esac
done
