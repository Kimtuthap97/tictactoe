#!/bin/bash

#Tic-tac-toe (Co caro 3 nuoc)

cell_w=10
# horizontal line
line_seg="---------"
line="  ""$line_seg""|""$line_seg""|""$line_seg"

# defines some colors
pink="\033[35m"
cyan="\033[36m"
blue="\033[34m"
green="\033[32m"
reset="\033[0m"

# defines players: human: 1: x
player_1_str=$green"Human"$reset
player_2_str=$blue"Computer"$reset

positions="---------"  # initial positions

player_one=true  # player switch init
game_finished=false  # is the game finished?
stall=false  # stall - if an invalid or empty move was input

# Dua ra positions tiep theo
# Tham so: positions, "o" hoac "x
function next {
	player=$2
	tempt=$1
	for i in `seq 0 8`; do # repeat all over 
		if [ "${temp:$i:1}" = "-" ]; then #Kiem tra vi tri -
			rest=`expr $i + 1`
			echo ${temp:0:$i}$player${temp:$rest} #positions moi
		fi
	done
}
function makeMove {
    local min=2
    for i in `seq 0 8`; do
		if [ "${positions:$i:1}" = "-" ]; then
			local rest=`expr $i + 1`
			local succ=${positions:0:$i}O${positions:$rest}
			minimax $succ 0 2
			local result=$? #Ket qua danh gia buoc di $succ
			if (( $result <= $min )); then
				min=$result
				next=$succ
			fi
		fi
    done
    positions=$next
}
# functions that draws instructions and board based on positions arr
# tham so: $1: array of positions
function draw_board {

  clear

  name=$1  # passing an array as argument
  positions="${!name}"

  # first lines - instructions
  echo -e "\n       Q W E       _|_|_\n        A S D   →   | | \n         Z X C     ‾|‾|‾\n\n"

  for (( row_id=1; row_id<=3; row_id++ ));do
    # row
    row="  "
    empty_row="  "
    for (( col_id=1; col_id<$(($cell_w*3)); col_id++ ));do
      # column

      # every 10th is a separator
      if [[ $(( $col_id%$cell_w )) == 0 ]]; then
        row=$row"|"
        empty_row=$empty_row"|"
      else
        if [[ $(( $col_id%5 )) == 0 ]]; then  # get the center of the tile

          x=$(($row_id-1))
          y=$((($col_id - 5) / 10))

          if [[ $x == 0 ]]; then
            what=${positions:$y:1}
          elif [[ $x == 1 ]]; then
            what=${positions:$y+3:1}
          else
            what=${positions:$y+6:1}
          fi

          # if it's "-", it's empty
          if [[ $what = "-" ]]; then what=" "; fi

          if [[ $what = "X" ]] ; then  # append to row
            row=$row$green$what$reset
          else
            row=$row$blue$what$reset
          fi

          empty_row=$empty_row" "  # advance empty row
        else  # not the center - space
          row=$row" "
          empty_row=$empty_row" "
        fi
      fi
    done
    echo -e "$empty_row""\n""$row""\n""$empty_row"  # row is three lines high
    if [[ $row_id != 3 ]]; then
      echo -e "$line"
    fi
  done
  echo -e "\n"
}

# function that displays the prompt based on turn, reads the input and advances the game
function read_move {

  positions_str=$(printf "%s" "${positions}")
  
  test_position_str $positions_str  # finish the game if all positions have been taken or a player has won
  local test=$?

  if [[ $test == 2 ]] ; then
	echo -e $player_1_str" wins! \n"
	end_game
  elif [[ $test == 0 ]] ; then
		echo -e $player_2_str" wins! \n"
		end_game
   elif [[ $test == 1 ]] ; then
		echo -e "End with a "$pink"draw"$reset"\n"
		end_game
  fi
  
  if [ $game_finished = false ] ; then
	
    if [ $stall = false ] ; then
      if [ $player_one = true ] ; then
        prompt="Your move, "$player_1_str"?"
      fi
    else
      stall=false
    fi

    if [ "$player_one" = true ] ; then
      echo -e $prompt
      read -d'' -s -n1 input  # read input

      index=10  # init with nonexistent
      case $input in
            q) index=0;;
            a) index=3;;
            z) index=6;;
            w) index=1;;
            s) index=4;;
            x) index=7;;
            e) index=2;;
            d) index=5;;
            c) index=8;;
      esac

      if [ "${positions:$index:1}" = "-" ]; then
		local rest=`expr $index + 1`
	    positions="${positions:0:$index}X${positions:$rest}"
        player_one=false
      else
        stall=true  # prevent player switch
      fi

    else
      # computer, choose your position!
	  echo -e $pink"I'm thinking..."$reset" Please wait !"
      makeMove
      player_one=true
    fi
    init_game  # reinit, because positions persist
  fi
}

function init_game {
  draw_board positions
  read_move
}

function end_game {
  game_finished=true
}

function test_position_str {
	temp=$1;
	space=" "
	#rows=${temp:0:3}$space${temp:3:3}$space${temp:6:3}
	#cols=${temp:0:1}${temp:3:1}${temp:6:1}$space${temp:1:1}${temp:4:1}${temp:7:1}$space${temp:2:1}${temp:5:1}${temp:8:1}
	#diagonals=${temp:0:1}${temp:4:1}${temp:8:1}$space${temp:2:1}${temp:4:1}${temp:6:1}
	
	rows=${1:0:3}" "${1:3:3}" "${1:6:8}
	cols=${1:0:1}${1:3:1}${1:6:1}" "${1:1:1}${1:4:1}${1:7:1}" "${1:2:1}${1:5:1}${1:8:1}
	diagonals=${1:0:1}${1:4:1}${1:8:1}" "${1:2:1}${1:4:1}${1:6:1}
	
	if [[ $rows =~ [X]{3,} || $cols =~ [X]{3,} || $diagonals =~ [X]{3,} ]]; then
		return 2 # Nguoi thang
	elif [[ $rows =~ [O]{3,} || $cols =~ [O]{3,} || $diagonals =~ [O]{3,} ]]; then
		return 0 # May thang
	elif [[ $temp = *"-"* ]]; then
		return 4 # Van con choi
	else
		return 1 # Hoa
	fi
}

# Tra ve $v: danh gia cac buoc di
# Tham so dau vao: $positions, $alpha, $beta
# Tra ve 0: Hoa, 1: may thang, 2: nguoi thang
function minimax { 
	local currpositions=$1
	test_position_str $currpositions
	local result=$?
	
    if [[ $result < 3 ]]; then
	return $result
    else
	local alpha=$2
	local beta=$3
	maxplayer $1
	if [ $? -eq 0 ]; then # if maxplayer function returns 0, it is max's turn
	    local v=0
	    for s in `next $currstate "x"`; do
		minimax $s $alpha $beta
		local temp=$?
		if [[ $temp > $v ]]; then
		    v=$temp
		fi
		if (( $v >= $beta )); then
		    return $v
		fi
		if [[ $v > $alpha ]]; then
		    alpha=$v
		fi
	    done
	    return $v
	else
	    local v=2
	    for s in `next $currstate "o"`; do
		minimax $s $alpha $beta
		local temp=$?
		if [[ $temp < $v ]]; then
		    v=$temp
		fi
		if (( $v <= $alpha )); then
		    return $v
		fi
		if [[ $v < $beta ]]; then
		    beta=$v
		fi
	    done
	    return $v
	fi
    fi
}

# Tra ve 0: luot di cua nguoi
# Tra ve 1: luot di cua may
# Tham so: positions
function maxplayer {
	free=`echo $1 | sed 's/[XO]//g'`
	if [ `expr ${#free} % 2` -eq 1 ]; then
		return 0
	else
		return 1
	fi
}

init_game