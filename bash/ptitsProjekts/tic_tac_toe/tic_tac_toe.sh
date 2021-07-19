#!/usr/bin/env bash

# Simple Tic Tac Toe game in bash

declare -r myname='Simple Tic Tac Toe'
declare -r myver='0.1'

# Generic function
usage(){
  echo ${myname}$myver
  echo
  echo "Simple Tic Tac Toe game in bash"
  echo
  echo "Usage: ${myname}.sh"
}

##############################
### VARIABLES DECLARATIONS ###
##############################
declare -a players
players[1]="X"
players[2]="0"
currentPlayer="1"
currentPlayerSign="$player1"
nextPlayer="1"
vsComputer="0"
# TTTBoard emulates 2D Array in bash (i,j).
# draoBTTT addresses each cases with a different number: number as indexes and coordinates as values.
# draoBTTT is needed because TTTBoard is an associative array.
# it means its content is not ordered by alphanum order, it is "randomized".
# See printBoard function.
declare -A TTTBoard
declare -a draoBTTT

##################
### FUNCTIONS  ###
##################

# Number of Players
soloGame(){
  while [[ ! "$nb" =~ ^[1-2]$ ]]; do
    echo "$IFS"
    read -p "1 or 2 players? " nb
  done
  return $(( "$nb" - 1 )) # return 0 (true in bash) or 1
}

# Initialization of the board
initBoard(){
  soloGame && vsComputer="1"
  # Gives random sign for each player
  (( RANDOM % 2 )) && players[1]="O" && players[2]="X"
  # Generate a board 3x3 with cases marked from 1 to 9
  local k=1
  for i in {1..3}; do
    for j in {1..3}; do
      TTTBoard[$i,$j]="$k"
      draoBTTT[$k]="$i,$j"
      ((k++))
    done
  done
}

# Printing the Board
printBoard(){
  echo
  echo "Player 1: ${players[1]}"
  # Return error because soloGame is undifined
  [ "$vsComputer" -eq 1 ] && echo "Computer : ${players[2]}" || echo "Player 2: ${players[2]}"
  echo
  # for loop must output associative array in the right order
  printf " %1s | %1s | %1s\n --|---|--\n" $(for key in ${draoBTTT[*]}; do printf "%s " "${TTTBoard[$key]}"; done)
  echo
}

# Legal moves
playin(){
  local validCase="false"
  local caseChosen
  exec 3>&2 # saves stderr fd to fd 3
  while [[ "$caseChosen" != "$validCase" ]]; do
    read -p "Please, choose a valid case to play: " -n 1 caseChosen
    echo
    exec 2> /dev/null # redirect stderr to /dev/null to prevent bad Array ERROR
    validCase="${TTTBoard[${draoBTTT[$caseChosen]}]:-false}"
    exec 2>&3 # restore sdterr fd
  done
  TTTBoard[${draoBTTT[$caseChosen]}]="$currentPlayerSign"
}
# /!\ is there a way to use trap in a more nicer way than the exec hack?

# Winner checks
# Each function takes pattern as arg

# Rows
checkRow(){
  for i in {1..3}; do
    local row=""
    for j in {1..3}; do
      row+=${TTTBoard[$i,$j]}
    done
    test "$1" = "$row" && return 0 # found a winner
  done
  return 1 # no winner yet
}

# Columns
checkCol(){
  for j in {1..3}; do
    local col=""
    for i in {1..3}; do
      col+=${TTTBoard[$i,$j]}
    done
    test "$1" = "$col" && return 0 # found a winner
  done
  return 1
}

# Diag
checkDiag(){
  local diag1=""
  local diag2="${TTTBoard[1,3]}${TTTBoard[2,2]}${TTTBoard[3,1]}"
  for i in {1..3}; do
    diag1+="${TTTBoard[$i;$i]}"
  done
  test "$1" = "$diag1" -o "$1" = "$diag2" && return 0 # found a winner
  return 1
}

winner(){
  echo "Player $currentPlayer WON !"
  printBoard
  echo
  echo "exiting the game..."
  exit 0
}

# A turn
playerTurn(){
  # Switching players
  currentPlayer="$nextPlayer"
  currentPlayerSign="${players[$currentPlayer]}"
  # Printing Board
  printBoard
  # Player can play
  playin
  # Presetting nextplayer
  test "$currentPlayer" = "1" && nextPlayer="2" || nextPlayer="1"
}

# Whole game
wholeGame(){
  for turn in {1..9}; do
    echo
    echo "TURN $turn"
    case "$turn" in
      # No winner during the 4 firsts rounds
      [1-4]) playerTurn ;;
      *)
        playerTurn
        # Checking for winner
        pattern="${currentPlayerSign}${currentPlayerSign}${currentPlayerSign}"
        ( checkRow "$pattern" || checkCol "$pattern" || checkDiag "$pattern" ) && winner
        ;;
    esac
  done
  echo "It's a DRAW !"
  exit 0
}

############
### MAIN ###
############
initBoard
wholeGame
