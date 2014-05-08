#!/bin/bash
set -eo pipefail

# Temporary empty dir to created named pipes (fifos)
# that will be needed to keep track of the created process PIDs
# while also formatting their output at the same time.
temp_dir=`mktemp -d /tmp/shoreman.XXXXXXXXXX`

# This function formats all text coming from STDIN to look like:
# process_name | output
# ensuring a fixed distance of 12 chars until the separating pipe
# the result is that it's clear what's coming from where.
# the usage is: command_to_format | log process_name
log() {
  awk_cmd="{ printf \"%-12s | %s\\n\", \"$1\", \$1}"
  cat - | awk -F'|' "$awk_cmd"
}

# Associative data storage use to link a process PID with
# the name it was given in the Procfile
hput () {
  eval hash"$1"='$2'
}

hget () {
  eval echo '${hash'"$1"'#hash}'
}

# Convenient function to scope shoreman's own output
info() {
  echo "$1" | log "shoreman"
}

# When a process with a name and a command is read from the
# Profile. this function launches the command, stores it's pid
# informs that PID to the user and then passed the command output
# through the log function for pretty formatting.
start_command() {
  name=$2
  cmd=$1

  # Named pipes are used to know the launched command PID
  # while keeping the posibility of redirecting it's output
  cmd_fifo=$temp_dir/$name
  mkfifo $cmd_fifo

  # We send the executed command output to 
  #bash -lc "$cmd &> $cmd_fifo" &
  ($cmd &> $cmd_fifo) &
  pid="$!"
  pids=("${pids[@]}" "$pid")

  log $name < $cmd_fifo &
  # Associate pid with name for better error messages
  hput $pid $name
  info "$name started with pid=$pid"
}

info "shoreman started with pid=$$"

# ## Reading the .env file

# The .env file needs to be a list of assignments like in a shell script.
# Only lines containing an equal sign are read, which means you can add comments.
# Preferably shell-style comments so that your editor print them like shell scripts.

env_file=${2:-'.env'}
if [ -f $env_file ]; then
  while read line || [ -n "$line" ]; do
    if [[ "$line" != \#* && "$line" == *=* ]]; then
      eval "export $line"
    fi
  done < "$env_file"
fi

# ## Reading the Procfile

# The Procfile needs to be parsed to extract the process names and commands.
# The file is given on stdin, see the `<` at the end of this while loop.
procfile=${1:-'Procfile'}
while read line || [ -n "$line" ]; do
  name=${line%%:*}
  command=${line#*: }
  start_command "$command" $name
done < "$procfile"

# ## Process management

# This sends the signal passed as first argument to all alive processes
# in the $pids array, ignoring errors.  
# It prints log messages if the second parameter is 1.
send_signal() {
  for pid in "${pids[@]}"; do
    # Only run if the process exists
    if kill -0 $pid &> /dev/null; then
      if [[ "$2" == "1" ]]; then
        info "Sending $1 to `hget $pid`"
      fi
      # Ignore errors
      kill -s $1 $pid &> /dev/null || :
    fi
  done
}

# When a `SIGINT` or `SIGTERM` is received, this action is run, signaling the
# child processes with SIGTERM to gracefully shutdown within 3 seconds.
# After that waitime, any remaining children are all killed with SIGKILL.
# Shoreman does its best to avoid any process from outliving it.
onexit() {
  # An explanation for the exit is passed as first param
  info "$1"
  info "Terminating all processes"

  # the 0 means don't print messages
  send_signal SIGTERM 0

  info "Waiting 3s for children termination"
  sleep 3

  # we disown all jobs to prevent error messages
  # when we try to kill them
  disown -a

  # the 1 causes a message to be printed for each
  # misbehaving process that didn't exit gracefully
  send_signal SIGKILL 1

  info 'Removing temporary files'
  rm -rf $temp_dir && info 'OK'

  exit 0
}

trap 'onexit "SIGINT received."' SIGINT
trap 'onexit "SIGTERM received."' SIGTERM
trap 'onexit "EXIT signal"' SIGTERM

while true; do
  for pid in "${pids[@]}"; do
    if ! kill -0 $pid &> /dev/null; then
      onexit "Error: `hget $pid` is no longer running"
    fi
  done
  sleep 0.5
done
