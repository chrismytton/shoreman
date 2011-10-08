#!/bin/sh

set -e

#/ Usage: shoreman [<procfile>]
#/ Run Procfiles using shell.
#/
#/ The shoreman script reads commands from <procfile> and starts up the
#/ processes that it descripbes.

# Stolen from shocco
expr -- "$*" : ".*--help" >/dev/null && {
  grep '^#/' <"$0" | cut -c4-
  exit 0
}

store_pid() {
  pids=("${pids[@]}" "$1")
}

while read line
do
  name=$(echo "$line" | cut -f1 -d:)
  command=$(echo $(echo "$line" | cut -f2- -d:))

  sh -c "$command" &

  pid="$!"
  store_pid "$pid"
  echo "${name}.1[${pid}]: ${command}"
done < ${1:-'Procfile'}

for p in "${pids[@]}"
do
  pid_string="${pid_string}${p} "
done

trap_action="echo && \
  echo sending SIGTERM to all processes && \
  kill $pid_string && \
  sleep 1"

trap "$trap_action" INT TERM
wait $pid_string
