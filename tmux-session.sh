#!/bin/bash

clear

pane_test() {
  until [ -z "$1"  ]  # Until all parameters used up . . .
  do
    echo
    child=$(pgrep -P $1)
    echo -n "command: "
    if [ -z $child ]
    then
      ps -o 'args=' -p $1
    else
      ps -o 'args=' -p $child
    fi
    echo -n "directory: "
    echo "$2 "
    shift 2
  done
  #child=$(pgrep -P $p)
}

pane_parameters() {
  ps -opid,ppid,args -p $1
  echo -e "$1\n"
}

window_parameters() {
  echo $1 # session_name
  echo $2 # window_index
  echo $3 # window_name
  echo $4 # window_panes
  echo $5 # window_layout

  #tmux list-panes -t $1:$2
  panes=$(tmux list-panes -t $1:$2 -F "#{pane_pid} #{pane_current_path}")
  pane_test $panes
}

windows=$(tmux list-windows -F "#{session_name} #{window_index} #{window_name} #{window_panes} #{window_layout}")

while read window
do
  #echo $window
  window_parameters $window
  echo
done <<< "$windows"


 #air 1 components 2 8042,150x39,0,0{75x39,0,0,0,74x39,76,0,3}
 #air 2 ruby-tapas 1 cdbe,150x39,0,0,1
 #air 3 src 2 cd4c,150x39,0,0[150x30,0,0,4,150x8,0,31,6]
 #air 4 bash 2 a6f5,150x39,0,0[150x30,0,0,9,150x8,0,31,10]
