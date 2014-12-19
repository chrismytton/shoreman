#!/bin/bash

# [shoreman](https://github.com/hecticjeff/shoreman) is an
# implementation of the **Procfile** format. Inspired by the original
# [foreman](http://ddollar.github.com/foreman/) tool for ruby, as
# well as [norman](https://github.com/josh/norman) for node.js.

# Make sure that any errors cause the script to exit immediately.
set -eo pipefail
[[ "$TRACE" ]] && set -x

# ## Usage

# Usage message that is displayed when `--help` is given as an argument.
usage() {
  echo "Usage: shoreman [procfile|Procfile] [envfile|.env]"
  echo "Run Procfiles using shell."
  echo
  echo "The shoreman script reads commands from [procfile] and starts up the"
  echo "processes that it describes."
}

# ## Logging

# For logging we want to prefix each entry with the current time, as well
# as the process name. This takes one argument, the name of the process, and
# then reads data from stdin, formats it, and sends it to stdout.
log() {
  local pid="$!"
  # Bash colors start from 31 up to 38. Instead of a hash set and storing a
  # bunch of variables, we will simply calculate what color the process will get
  # base on its PID
  local color="$((31 + (pid % 7)))"

  while read -r data
  do
    printf "\033[1;%sm%s %s\033[0m" "$color" "$(date +"%H:%M:%S")" "$1"
    printf "\t| %s\n" "$data"
  done
}

# ## Running commands

# When a process is started, we want to keep track of its pid so we can
# `kill` it when the parent process receives a signal, and so we can `wait`
# for it to finish before exiting the parent process.
store_pid() {
  pids="$pids $1"
}

# This starts a command asynchronously and stores its pid in a list for use
# later on in the script.
start_command() {
  bash -c "$1" 2>&1 | log "$2" &
  pid="$(jobs -p %%)"
  store_pid "$pid"
}

# ## Reading the .env file

# The .env file needs to be a list of assignments like in a shell script.
# Shell-style comments are permitted.
load_env_file() {
  local env_file=${1:-'.env'}

  # Set a default port before loading the .env file
  export PORT=${PORT:-5000}

  if [[ -f "$env_file" ]]; then
    export $(grep "^[^#]*=.*" "$env_file" | xargs)
  fi
}

# ## Reading the Procfile

# The Procfile needs to be parsed to extract the process names and commands.
run_procfile() {
  local procfile=${1:-'Procfile'}
  local IFS=$'\n'
  local lines=( $(grep "^[A-Za-z0-9_-]\{1,\}:[[:space:]]*.\{1,\}" "$procfile") )
  local line=''

  for line in "${lines[@]}"; do
    local name="${line%%:*}"
    local command="${line#*:}"

    # trim
    command="${command#"${command%%[![:space:]]*}"}"
    command="${command%"${command##*[![:space:]]}"}"

    start_command "$command" "${name}"
    echo "'${command}' started with pid $pid" | log "${name}"
  done
}

# ## Cleanup

# When a `SIGINT`, `SIGTERM` or `EXIT` is received, this action is run, killing the
# child processes. The sleep stops STDOUT from pouring over the prompt, it
# should probably go at some point.
onexit() {
  echo "SIGINT received"
  echo "sending SIGTERM to all processes"
  kill $pids
  sleep 1
}

main() {
  local procfile="$1"
  local env_file="$2"

  # If the --help option is given, show the usage message and exit.
  expr -- "$*" : ".*--help" >/dev/null && {
    usage
    exit 0
  }

  load_env_file "$env_file"
  run_procfile "$procfile"

  trap onexit INT TERM

  # Wait for the children to finish executing before exiting.
  wait $pids
}

main "$@"
