#!/usr/bin/env bash

#### Variables ####
TODAY=$(date +"%a")     # Todays'day 3 first chars
YEAR=$(date +"%Y")      # Current year
MONTH=$(date +"%B")     # Current month
month_start=()          # Empty element array to init calendar            
month_days=()           # Array for calendar with all days number
weekday_nbr=            # Weekday as number (0 to 6)
nbr_day_month=          # number of day in the month
month_start_empty=      # number of empty day in the calendar beginning
calendar=()             # Array for all days in the current month + empty element if 1st of month isnt a sunday

#### Fonctions ####
# Translate day name in number in the week aka date +"%w"
#weekday_name_to_nbr(){
#    case "$1" in
#        Sun)
#            echo 0
#            ;;
#        Mon)
#            echo 1
#            ;;
#        Tue)
#            echo 2
#            ;;
#        Wed)
#            echo 3
#           ;;
#        Thu)
#            echo 4
#            ;;
#        Fri)
#            echo 5
#            ;;
#        Sat)
#            echo 6
#            ;;
#    esac
#}

# Is it a leap year ?
leapyear(){
    if (( ("$1" % 400) == "0" )) || (( ("$1" % 4 == "0") && ("$1" % 100 != "0") )); then
        true;
    else
        false;
    fi
}

# Is it february ?
february(){
    [[ "$1" == "February" ]]
}

# 30 or 31 days
thirty_plus_one(){
    case $1 in
        Apr|Jun|Sep|Nov)
            echo 30
            ;;
        *)
            echo 31
            ;;
    esac
}

# Return number of day in a month
day_month(){
    if [[ $(february ${MONTH}) ]] && [[ $(leapyear ${YEAR}) ]]; then
        echo 29
    elif [[ $(february ${MONTH}) ]]; then
        echo 28
    else
        thirty_plus_one $(date +"%b")
    fi
}
# Number of first sunday of the month
first_sunday(){
    echo $(( ($(date +"%d")-$(date +"%w")) %7))
}
# First day of the month
first_day_month(){
    sunday=$(first_sunday "$1")
    case $sunday in
        1)
            echo "0"
            ;;
        2)
            echo "6"
            ;;
        3)
            echo "5"
            ;;
        4)
            echo "4"
            ;;
        5)
            echo "3"
            ;;
        6)
            echo "2"
            ;;
        0)
            echo "1"
            ;;
    esac
}

    
#### Creating Calendar array ####
# /!\ This could/should be a fonction /!\ <<<<<<<<<<<<<<<<<<<<<<<<
nbr_day_month=$(day_month)
month_start_empty=$(first_day_month)
for (( i=0; i<$month_start_empty; i++ )); do
    month_start[${i}]="32"
done
for (( i=1; i<=$nbr_day_month; i++ )); do
    month_days[${i}]=$i
done

calendar=(${month_start[@]} ${month_days[@]})
#### PRINT ####
date +"     %A, %dth"
date +"     %B %Y"
number=1
for i in ${calendar[@]}; do
    printf "%s " ${i}
    (( ("$number" % 7) == 0 )) && echo
    ((number++))
done | column -t -N Su,Mo,Tu,We,Th,Fr,Sa | sed 's/\<32/  /g'
