describe "Shoreman"

it_displays_usage() {
  usage=$(bash ./shoreman.sh --help | head -n1)
  test "$usage" = "Usage: shoreman [<procfile>]"
}

it_runs_simple_processes() {
  output=$(bash ./shoreman.sh 'test/fixtures/simple_procfile' | head -n1)
  test "$output" = "Hello"
}

it_passes_environment_variables_to_processes() {
  output=$(FOO=bar bash ./shoreman.sh 'test/fixtures/environment_procfile' | head -n1)
  test "$output" = "FOO = bar"
}

it_automatically_assigns_a_port() {
  output=$(bash ./shoreman.sh 'test/fixtures/port_procfile' | head -n1)
  test "$output" = "PORT = 5000"
}
