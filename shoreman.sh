#!/bin/sh
# **shoreman** is an implementation of the **Procfile** format. Inspired by
# the original [foreman](http://ddollar.github.com/foreman/) tool for ruby,
# as well as [norman](https://github.com/josh/norman) for node.js.

# Make sure that any errors cause the script to exit immediately.
set -e

# Usage message that is displayed when `--help` is given as an argument.
#/ Usage: shoreman [<procfile>]
#/ Run Procfiles using shell.
#/
#/ The shoreman script reads commands from <procfile> and starts up the
#/ processes that it describes.

# ## Utilities

# Stolen from shocco. This formats the usage message above by grepping this
# file for lines starting with `#/`.
expr -- "$*" : ".*--help" >/dev/null && {
  grep '^#/' <"$0" | cut -c4-
  exit 0
}

# When a process is started, we want to keep track of its pid so we can
# `kill` it when the parent process receives a signal, and so we can `wait`
# for it to finish before exiting the parent process.
store_pid() {
  pids=("${pids[@]}" "$1")
}

# For logging we want to prefix each entry with the current time, as well
# as the process name. This takes one argument, the name of the process, and
# then reads data from stdin, formats it, and sends it to stdout.
log() {
  while read data
  do
    echo "$(date +"%H:%M:%S") $1\t| $data"
  done
}

# ## Reading the Procfile

# The Procfile needs to be parsed to extract the process names and commands.
# The file is given on stdin, see the `<` at the end of this while loop.
while read line
do
  name=$(echo "$line" | cut -f1 -d:)
  command=$(echo $(echo "$line" | cut -f2- -d:))

  sh -c "$command" &

  pid="$!"
  store_pid "$pid"
  echo "${name}.1[${pid}]: ${command}"
done < ${1:-'Procfile'}

# ## Cleanup

# When a `SIGINT` or `SIGTERM` is received, this action is run, killing the
# child processes. The sleep stops STDOUT from pouring over the prompt, it
# should probably go at some point.
trap_action="echo SIGINT received && \
  echo sending SIGTERM to all processes | log system && \
  kill ${pids[@]} && \
  sleep 1"

trap "$trap_action" INT TERM

# Wait for the children to finish executing before exiting.
wait ${pids[@]}