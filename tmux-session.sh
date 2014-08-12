#]!/bin/bash

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
    #echo "$3 "
    shift 3
  done
  #child=$(pgrep -P $p)
}

pane_test() {
  #echo $@
  #echo
  echo $1 $2 $3 $4 $5
  initial_window=true
  initial_pane=true
  session=$1
  window_index=$2
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

    if [ "$session" = "$last_session" ]; then
      initial_window=false
    fi
    if [ "$window_index" = "$last_window" ]; then
      initial_pane=false
    fi

#    echo
#    echo '###'
#    echo initial session: $initial_session
#    echo window index: $window_index
#    echo last window: $last_window
#    echo initial window: $initial_window
#    echo initial pane: $initial_pane
#    echo '###'
#    echo
#
    if [ "$initial_window" == "true" ] && [ "$initial_pane" = "true" ]; then
      echo "tmux new-session -d -s $session"
      initial_session=false
    elif [ "$initial_window" == "true" ] || [ "$initial_pane" = "true" ]; then
      echo "tmux new-window -d -t $session:$window_index"
    else
      echo "tmux split-window -d -t $session:$window_index"
    fi
    last_session=$session
    last_window=$window_index
    #echo tmux send-keys -t $session:$window_index \"$command\" C-m
    #echo $layout
    #echo $last_window
    #echo $initial_pane
    #echo "$3 "
    echo tmux select-layout -t $last_session:$last_window \"$layout\" \> /dev/null
    shift 3
  done >> ./test_session
}

window_parameters() {
  #tmux list-panes -t $1:$2
  session=$1
  window_index=$2
  name=$3
  nr_of_panes=$4
  layout=$5

  panes=$(tmux list-panes -t $1:$2 -F "#{pane_pid} #{pane_current_path} #{pane_current_command}")
  pane_test $session $window_index $nr_of_panes $name $layout $panes
}

# clear test session file before launch
> ./test_session

#echo tmux start-server >> ./test_session

if $(tmux has-session)
then
  echo tmux is running.
  echo Saving session and attaching...
  #tmux -2u att
fi

windows=$(tmux list-windows -a -F "#{session_name} #{window_index} #{window_name} #{window_panes} #{window_layout}")

while read window
do
  #echo $window
  window_parameters $window
  echo
done <<< "$windows"

cat ./test_session
