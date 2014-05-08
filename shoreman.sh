#!/bin/bash

# [shoreman](https://github.com/hecticjeff/shoreman) is an
# implementation of the **Procfile** format. Inspired by the original
# [foreman](http://ddollar.github.com/foreman/) tool for ruby, as
# well as [norman](https://github.com/josh/norman) for node.js.

# Make sure that any errors cause the script to exit immediately.
set -eo pipefail

# Usage message that is displayed when `--help` is given as an argument.
usage() {
  echo "Usage: shoreman [<procfile>]"
  echo "Run Procfiles using shell."
  echo
  echo "The shoreman script reads commands from <procfile> and starts up the"
  echo "processes that it describes."
}

# If the --help option is given, show the usage message and exit.
expr -- "$*" : ".*--help" >/dev/null && {
  usage
  exit 0
}

# Temporary empty dir to store named pipes that will
# be needed to keep track of the created processes PIDs
# and still be capable of formatting their output.
temp_dir="${TMPDIR:-/tmp}/shoreman.$$"
mkdir -p "$temp_dir"

# Format all text coming from STDIN to look like:
# some_app     | output ...
log_as() {
  # ensure there are 12 chars before the separating pipe.
  awk_cmd="{ printf \"%-12s | %s\\n\", \"$1\", \$1}"
  cat - | awk -F'|' "$awk_cmd"
}

# Associative data storage used to link a process PID's with
# its Procfile name. Used for better errors.
hput () {
  eval hash"$1"='$2'
}

hget () {
  eval echo '${hash'"$1"'#hash}'
}

# Convenience function to identify shoreman's own output.
log() {
  echo "$1" | log_as "shoreman"
}

# When a process with a name and a command is read from the
# Profile. this function launches the command, stores it's pid
# prints that PID to the user and then pipes the command output
# through the log_as function for pretty formatting.
start_command() {
  name=$2
  cmd=$1

  # Named pipes are used to know the launched command PID
  # while keeping the posibility of redirecting it's output
  cmd_fifo=$temp_dir/$name
  mkfifo $cmd_fifo

  # We send the executed command output to 
  #bash -lc "$cmd &> $cmd_fifo" &
  bash -c "$cmd" &> $cmd_fifo &
  pid="$!"
  pids=("${pids[@]}" "$pid")

  log_as $name < $cmd_fifo &
  # Associate pid with name for better error messages
  hput $pid $name
  echo "Started with pid $pid" | log_as $name
}

# ## Reading the .env file

# The .env file needs to be a list of assignments like in a shell script.
# Only lines containing an equal sign that don't begin with # are read, this 
# means you can add shell-style comments.

env_file=${2:-'.env'}
if [ -f $env_file ]; then
  while read line || [ -n "$line" ]; do
    if [[ "$line" != \#* && "$line" == *=* ]]; then
      eval "export $line"
    fi
  done < "$env_file"
fi

# ## Reading the Procfile

procfile=${1:-'Procfile'}

if [[ -e "$procfile" ]]; then
  
  log "Started with pid $$"

  # The Procfile needs to be parsed to extract the process names and commands.
  # The file is given on stdin, see the `<` at the end of this while loop.
  while read line || [ -n "$line" ]; do
    name=${line%%:*}
    command=${line#*: }
    start_command "$command" $name
  done < "$procfile"

else

  echo "Procfile doesn't exist."
  exit 1

fi

# ## Process management

# This sends the signal passed as first argument to all alive processes
# in the $pids array, ignoring errors.  
# It prints messages if the second parameter is 1.
send_signal() {
  for pid in "${pids[@]}"; do
    # Only run if the process exists
    if kill -0 $pid &> /dev/null; then
      if [[ "$2" == "1" ]]; then
        log "Sending $1 to `hget $pid`"
      fi
      # Ignore errors
      kill -s $1 $pid &> /dev/null || :
    fi
  done
}

any_children_alive() {
  for pid in "${pids[@]}"; do
    if kill -0 $pid &> /dev/null; then
      return 0
    fi
  done
  return 1
}

# When a `SIGINT` or `SIGTERM` is received, this action is run, signaling the
# child processes with SIGTERM to gracefully shutdown within 3 seconds.
# After that time, any remaining children killed with SIGKILL.
# Shoreman does its best to avoid any process from outliving it.
onexit() {
  # An explanation for the exit is passed as first param
  [[ -n "$1" ]] && log "$1"
  log "Terminating all processes"

  # the 0 means don't print messages
  send_signal SIGTERM 0
  sleep 0.5

  if any_children_alive; then
    log "Waiting 3s for children termination"
    sleep 3

    # we disown all jobs to prevent error messages
    # when we try to kill them
    disown -a

    # the 1 causes a message to be printed for each
    # misbehaving process that didn't exit gracefully
    send_signal SIGKILL 1

    # Can this happen? Maybe in a case of process permissions?
    any_children_alive && log "WARNING: some children were not killed by SIGKILL"
  fi

  log 'Removing temporary files'
  rm -rf "$temp_dir" && log 'OK'

  exit 0
}

trap 'onexit "SIGINT received."' SIGINT
trap 'onexit "SIGTERM received."' SIGTERM
trap 'onexit "EXIT signal"' SIGTERM

while true; do
  for pid in "${pids[@]}"; do
    if ! kill -0 $pid &> /dev/null; then
      echo "Exited" | log_as "`hget $pid`"
      onexit
    fi
  done
  sleep 0.5
done
