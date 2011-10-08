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

# Stolen from shocco
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

# Gather the pids into a space delimited string for handing to `kill` and
# `wait`.
for p in "${pids[@]}"
do
  pid_string="${pid_string}${p} "
done

# When a `SIGINT` or `SIGTERM` is received, this action is run, killing the
# child processes. The sleep stops STDOUT from pouring over the prompt, it
# should probably go at some point.
trap_action="echo && \
  echo sending SIGTERM to all processes && \
  kill $pid_string && \
  sleep 1"

trap "$trap_action" INT TERM

# Wait for the children to finish executing before exiting.
wait $pid_string
