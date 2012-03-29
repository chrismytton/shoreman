describe "Shoreman"

it_displays_usage() {
  usage=$(sh ./shoreman.sh --help | head -n1)
  test "$usage" = "Usage: shoreman [<procfile>]"
}

it_runs_simple_processes() {
  output=$(sh ./shoreman.sh 'test/fixtures/simple_procfile' | head -n1)
  test "$output" = "Hello"
}

it_passes_environment_variables_to_processes() {
  output=$(FOO=bar sh ./shoreman.sh 'test/fixtures/environment_procfile' | head -n1)
  test "$output" = "FOO = bar"
}
