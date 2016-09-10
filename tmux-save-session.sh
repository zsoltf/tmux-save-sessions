#!/bin/bash

# __ __|                              ___|                    _)
#    |  __ `__ \   |   | \ \  /     \___ \    _ \   __|   __|  |   _ \   __ \    __|
#    |  |   |   |  |   |  `  <            |   __/ \__ \ \__ \  |  (   |  |   | \__ \
#   _| _|  _|  _| \__,_|  _/\_\     _____/  \___| ____/ ____/ _| \___/  _|  _| ____/
#
####################################################################################
# save the windows, panes and layouts
# of all running tmux sessions to a bash script

construct_panes() {
  initial_window=true
  initial_pane=true
  session=$1
  window_index=$2
  window_name=$4
  layout=$5
  shift 5

  while [ $# -gt 2 ] ; do
    # get child process of pane
    child=$(pgrep -P $1)
    if [ -z $child ]
    then
      command=$(ps -o 'args=' -p $1)
    else
      command=$(ps -o 'args=' -p $child)
    fi

    case "$command" in
      sudo*|*bash*)
        command="echo $command";;
      vim*|top|tail*)
        command="$command";;
      *)
        command="echo $command";;
    esac

    [ "$session" = "$last_session" ] && initial_window=false
    [ "$window_index" = "$last_window" ] && initial_pane=false

    if [ "$initial_window" == "true" ] && [ "$initial_pane" = "true" ]; then
      echo "tmux new-session -d -n $window_name -s $session -c "$2""
      initial_session=false
    elif [ "$initial_window" == "true" ] || [ "$initial_pane" = "true" ]; then
      echo "tmux new-window -n $window_name -t $session:$window_index -c "$2""
    else
      echo "tmux split-window -t $session:$window_index -c "$2""
    fi
    # $3 - pane index
    echo "sleep 0.2"
    [ "$command" ] && echo tmux send-keys -t $session:$window_index.$3 \"$command\" Enter
    echo tmux select-layout -t $session:$window_index \"$layout\" \> /dev/null
    last_session=$session
    last_window=$window_index
    shift 3
  done >> ./$filename
}

construct_window() {
  #tmux list-panes -t $1:$2
  session=$1
  window_index=$2
  name=$3
  nr_of_panes=$4
  layout=$5

  panes=$(tmux list-panes -t $1:$2 -F "#{pane_pid} #{pane_current_path} #{pane_index}")
  construct_panes $session $window_index $nr_of_panes $name $layout $panes
}

setup() {
  if ! $(tmux has-session 2>/dev/null); then
    echo No Sessions exist, exiting.
    exit
  fi
  timestamp=$(date "+%s")
  filename=./sessions-`date "+%F"`-${timestamp:6}.sh
  sessions=$(tmux list-sessions -F "#{session_name}")
  echo $sessions
  touch $filename
  echo '#!/bin/bash' >> $filename
  echo 'if $(tmux has-session 2>/dev/null); then tmux -2u att; exit; fi' >> $filename
}

teardown() {
  echo 'tmux -2u att' >> $filename
  chmod +x $filename
}

save_sessions() {
  windows=$(tmux list-windows -a -F "#{session_name} #{window_index} #{window_name} #{window_panes} #{window_layout}")
  while read window; do
    construct_window $window
  done <<< "$windows"
}

setup
save_sessions
teardown
