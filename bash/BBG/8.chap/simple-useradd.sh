#!/usr/bin/env bash

# simple-useradd.sh - Add a new user to the system

declare -r myname='simple-useradd'
declare -r myver='1.0'
AVAILABLE_SHELLS=(sh,bash)

### FUNCTIONS ###

usage() {
    echo "${myname} v${myver}"
    echo
    echo "Add a new user to the system."
    echo "Picks a free UID and creates a new unique group for this user, with a"
    echo "unique GID."
    echo 
    echo "You can add the user to extra groups, choose a login shell, set an expiration date and leave a comment to describe the account in an interactive way."
    echo
    echo "Usage: ${myname} USERNAME"
    echo "       ${myname} --version"
    echo "       ${myname} --help"
    echo
    echo "-v, --version      show programm's version number and exit"
    echo "-h, --help         show this help message and exit"
    
    exit 0
}

version() {
    echo "${myname} ${myver}"
    echo "No copyright."
    echo "No warranty."
    
    exit 0
}

err() {
    echo "Error $1" >&2
}

# Find and return a free ID for new user (UID) and new group (GID)
# Takes UID or GID as arg
find_free_id() {
    local file=/etc/passwd
    [ "$1" == "GID" ] && local file=/etc/group
    local HIGHEST_ID=$(awk 'BEGIN { FS=":" } ( $3 <= 60000 && $3 >= 1000 ) { print $3 }' $file | sort -n | tail -1)
    echo $((${HIGHEST_ID}+1))
}


### ARGUMENT PARSING ###

[ $# -eq 1 ] || err "Invalid arguments number."
[ $# -eq 1 ] || usage
case "$1" in
    \-h|\-\-help    ) usage ;;
    \-v|\-\-version ) version ;;
    *               )
        # Set USERNAME used for account creation
        # Verify if USERNAME is valid and not already used
        USERNAME="$1"
        until [[ "$USERNAME" =~ ^[a-z_][a-z0-9_]{0,30}$ ]] && [ ! $(egrep "^${USERNAME}\>" "/etc/passwd") ]; do
            err "Error: USERNAME exists or bad format."
            read -p "Choose your username: " USERNAME
        done
        echo
        echo "Your username is $USERNAME."
        echo
        ;;
esac


### PREP USERADD ###

# Picking unique UID
echo "Searching for available UID..."
U_UID=$(find_free_id "UID")
echo "$USERNAME UID is $U_UID."

# Picking unique GID and group name
echo "Searching for available unique group name and GID..."
U_GID=$(find_free_id "GID")
U_GROUP=$USERNAME
i=0
while [ $(egrep "^${U_GROUP}\>" /etc/group) ]; do
    ((i++))
    U_GROUP=${USERNAME}$i
done
echo "Your unique group name is $U_GROUP."
echo "$U_GROUP GID is $U_GID."

echo

# Ask for extra information
read -p "Extra group(s)(format: group1,group2,group3,...): " U_EXTRA_GROUP

until [ $(echo ${AVAILABLE_SHELLS[@]} | grep -o "\<${U_SHELL}\>") ]; do
    read -p "Login shell (${AVAILABLE_SHELLS[@]}) : " U_SHELL
done

# Date must be in the future
until [[ "$U_EXPI_DATE" =~ ^[0-9]{2}\/[0-9]{2}\/[2][0-9]{3}$ ]] && [[ $future == 'y' ]]; do 
    read -p "Expiration date (format mm/dd/yyyy): " U_EXPI_DATE
    [ $(date +%s) -lt $(date --date="$U_EXPI_DATE" +%s) ] && future='y'
done

# We could limit car number in U_COMMENT
read -p "Comment to describe this account: " U_COMMENT

# Check if Comment empty
[ "$U_COMMENT" ] || U_COMMENT=$USERNAME

echo

# Check if home directory does not exists
echo "Creating your home directory..."
i=0 
U_HOME=$USERNAME
while [ -d "/home/${U_HOME}" ]; do
    ((i++))
    U_HOME=${USERNAME}$i
done
echo "New home located at /home/${U_HOME}"

echo

# Creating new account
echo "Creating Account..."
echo "${USERNAME}:x:${U_UID}:${U_GID}:${COMMENT}:/home/${U_HOME}:/bin/${U_SHELL}" >> /etc/passwd
echo "${U_GROUP}:x:${U_GID}:${USERNAME}" >> /etc/group
echo "${USERNAME}:::::::${U_EXPI_DATE}:" >> /etc/shadow

while IFS=',' read -ra extra_group; do
    for group in "${extra_group[@]}"; do
        if [[ $(egrep "^${group}\>" /etc/group) =~ :$ ]]; then
            sed -i "/^${group}\>.*:$/ s/$/${USERNAME}/" /etc/group
        elif [[ $(egrep "^${group}\>" /etc/group) =~ [a-z0-9_]$ ]]; then
            sed -i "/^${group}\>.*[a-z0-9_]$/ s/$/,${USERNAME}/" /etc/group
        else
            err "${USERNAME} not added to ${group} group"
            err "${group} does not exists."
        fi
    done
done <<< "${U_EXTRA_GROUP}"
mkdir /home/${U_HOME}
chown -R ${USERNAME}:${U_GROUP} /home/${U_HOME}
echo "Account Created!"
echo "You may know choose a password."
# Modify passwd
passwd $USERNAME
