#!/bin/bash

pane_parameters() {
  initial_window=true
  initial_pane=true
  session=$1
  window_index=$2
  window_name=$4
  layout=$5
  shift 5

  while [ $# -gt 2 ] ; do
    child=$(pgrep -P $1)
    if [ -z $child ]
    then
      command=$(ps -o 'args=' -p $1)
    else
      command=$(ps -o 'args=' -p $child)
    fi

    if [ "$command" == "-bash" ]; then
      command="cd $2"
    else
      command="cd $2 && $command"
    fi

    [ "$session" = "$last_session" ] && initial_window=false
    [ "$window_index" = "$last_window" ] && initial_pane=false

    if [ "$initial_window" == "true" ] && [ "$initial_pane" = "true" ]; then
      echo "tmux new-session -d -n $window_name -s $session"
      initial_session=false
    elif [ "$initial_window" == "true" ] || [ "$initial_pane" = "true" ]; then
      echo "tmux new-window -d -n $window_name -t $session:$window_index"
    else
      echo "tmux split-window -d -t $session:$window_index"
    fi
    # need pane index for send-keys
    #echo tmux send-keys -t $session:$window_index \"$command\" C-m
    echo tmux select-layout -t $session:$window_index \"$layout\" \> /dev/null
    last_session=$session
    last_window=$window_index
    #echo $last_window
    #echo $initial_pane
    #echo "$3 "
    shift 3
  done >> ./$filename
}

window_parameters() {
  #tmux list-panes -t $1:$2
  session=$1
  window_index=$2
  name=$3
  nr_of_panes=$4
  layout=$5

  panes=$(tmux list-panes -t $1:$2 -F "#{pane_pid} #{pane_current_path} #{pane_current_command}")
  pane_parameters $session $window_index $nr_of_panes $name $layout $panes
}

if ! $(tmux has-session); then
  echo No Sessions exist, exiting.
  exit
fi


timestamp=$(date "+%s")
filename=./sessions-`date "+%F"`-${timestamp:6}.sh
touch $filename
echo '#!/bin/bash' >> $filename

windows=$(tmux list-windows -a -F "#{session_name} #{window_index} #{window_name} #{window_panes} #{window_layout}")

while read window; do
  window_parameters $window
done <<< "$windows"

chmod +x $filename
