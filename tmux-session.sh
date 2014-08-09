#!/bin/bash

clear

pane_parameters() {
  until [ -z "$1"  ]  # Until all parameters used up . . .
  do
    echo
    # get child process - mac ps doesn't have --ppid
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

window_parameters() {
  echo $1 # session_name
  echo $2 # window_index
  echo $3 # window_name
  echo $4 # window_panes
  echo $5 # window_layout

  #tmux list-panes -t $1:$2
  panes=$(tmux list-panes -t $1:$2 -F "#{pane_pid} #{pane_current_path}")
  pane_parameters $panes
}

windows=$(tmux list-windows -F "#{session_name} #{window_index} #{window_name} #{window_panes} #{window_layout}")

while read window
do
  #echo $window
  window_parameters $window
  echo
done <<< "$windows"
