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
    echo "$3 "
    shift 3
  done
  #child=$(pgrep -P $p)
}

pane_test() {
  echo $@
  echo
  echo $1 $2 $3 $4
  echo
  shift 4

  while [ $# -gt 2 ] ; do
    child=$(pgrep -P $1)
    echo
    echo -n "command: "
    if [ -z $child ]
    then
      ps -o 'args=' -p $1
    else
      ps -o 'args=' -p $child
    fi
    echo -n "directory: "
    echo "$2 "
    echo "$3 "
    shift 3
  done
}

window_parameters() {
  #tmux list-panes -t $1:$2
  session=$1
  name=$3
  nr_of_panes=$4
  layout=$5

  panes=$(tmux list-panes -t $1:$2 -F "#{pane_pid} #{pane_current_path} #{pane_current_command}")
  pane_test $session $nr_of_panes $name $layout $panes
}

windows=$(tmux list-windows -F "#{session_name} #{window_index} #{window_name} #{window_panes} #{window_layout}")

while read window
do
  #echo $window
  window_parameters $window
  echo
done <<< "$windows"
