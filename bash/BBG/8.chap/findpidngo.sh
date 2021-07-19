#!/usr/bin/env bash
#
# print the pid of full name of a process given as parameter and ONLY the pid
# Can change working directory using PID.

# NOTE: pretty hard to do it not using lower level language.

##############################
### Variables declarations ###
##############################

declare -r myname='findpidngo'
declare -r myver='1.0.0'
declare -r myprocess="$0 $@"
declare -r myprocess_pid="$$"
declare -a PROC_INFO
declare -a PID_LIST


#################
### Functions ###
#################

usage() {
        echo " ${myname} v${myver}"
        echo
        echo " Print PID of a process given in parameter."
        echo " Can change working directory to /proc/[pid]."
        echo
        echo " Usage: ${myname} [-c PARENT_DIRECTORY ][-m] PROCESSNAME"
        echo
        echo " Options:"
        echo "   --version       Show program's version number and exit."
        echo "   -h --help       Show this help message and exit."
        echo "   -c --changedir  Change working directory to PARENT_DIRECTORY/[PID], if multiple [PID] found, you get to choose :)"
        echo "   -m --more       Print more info about PID found." 
        echo
        echo " PROCESSNAME can either be the full name of the process or the command but also extended regular expression (ERE)."
}

version() {
        echo "${myname} ${myver} - 2018-11-03"
}

err() {
    echo " ERROR $@" >&2
    exit 1
}

# Returns PID + full process name, exclude PID of current process
# Takes PROCESS_NAME as 1st arg and shell PID as 2nd
get_pid() {
    pgrep -if "$1" -a
}

# Returns more info about process found: user and tty"
get_more() {
    ps -p "$1" -o "%p %u %y %a" h
}

# Change working directory
dir_change() {
     DIRECTORY="$1"
     PID="$2"
    if [[ ${DIRECTORY:${#DIRECTORY}-1:1} = / ]]; then
        [[ -d ${DIRECTORY}${PID} ]] || err "${DIRECTORY}${PID}: directory not found."
        change_dir "${DIRECTORY}${PID}"
    else
        [[ -d ${DIRECTORY}/${PID} ]] || err "${DIRECTORY}/${PID}: directory not found."
        change_dir "${DIRECTORY}/${PID}"
    fi
}



########################
### Argument parsing ###
########################

[[ $1 ]] || err
while [[ $1 ]]; do
    if [[ ${1:0:2} = -- ]]; then
        case "${1:2}" in
            help) usage; exit 0;;
            version) version; exit 0;;
            more)  MORE=1; shift ;;
            changedir) 
                 DIR_CHANGE=1 
                [[ $2 ]] || err "Must specify parent directory."
                [[ -d $2 ]] || err "$2: directory not found."
                 PARENT_DIR="$2" 
                shift 2
                ;;
            *) PROCESS_NAME="$1"; break
        esac
    elif [[ ${1:0:1} = - ]]; then
        case "${1:1}" in
            h) usage; exit 0;;
            m)  MORE=1; shift ;;
            c) 
                 DIR_CHANGE=1 
                [[ $2 ]] || err "Must specify parent directory."
                [[ -d $2 ]] || err "$2: directory not found."
                 PARENT_DIR="$2" 
                shift 2
                ;;
            *) PROCESS_NAME="$1"; break
        esac
    else
         PROCESS_NAME="$1"
        shift
        [[ $@ ]] && err "$@ unknown: too many args."
    fi
done



############
### MAIN ###
############

# 1. Prep
# Sanity check
[[ $PROCESS_NAME ]] || err "You must specify a process name or ERE to search for."

# Place proc information found into an array and pid to the list
declare -i i=0
while read line; do
    if [[ $line ]]; then
         first_part=$(cut -d " " -f 1 < <(echo ${line})) &&  second_part=$(cut -d " " -f 2- < <(echo ${line}))
        PID_LIST[${i}]=${first_part} &&  PROC_INFO+=(${second_part})
        i+=1
    fi
done <<< $(get_pid "${PROCESS_NAME}")
echo ${PID_LIST[@]}
# 2. Exec

# Not interactive
if [[ ${#PID_LIST} -ge 1  ]]; then

    # -m or not
    for nb_pid in $(seq 0 $((${#PID_LIST}-1))); do
        if [[ $MORE ]]; then
            echo "$nb_pid > $(get_more ${PID_LIST[${nb_pid}]})"
        else
            echo -e "$nb_pid > \t${PID_LIST[${nb_pid}]}\t${PROC_INFO[${nb_pid}]}"
        fi
    done

    # -c or not
    #if [[ $DIR_CHANGE ]]; then
    #    [[ ${#PID_LIST} == 1 ]] && (dir_change "$PARENT_DIR" "${PID_LIST[0]}"; break)
    #    echo "MULTIPLE"
    #fi
fi
