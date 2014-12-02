describe "Shoreman"

it_displays_usage() {
  usage=$(./shoreman.sh --help | head -n1)
  test "$usage" = "Usage: shoreman [processes]"
}

it_runs_simple_processes() {
  output=$(PROCFILE=test/fixtures/simple_procfile ./shoreman.sh; :)
  echo "$output" | grep -q "Hello"
}

it_passes_environment_variables_to_processes() {
  output=$(FOO=bar PROCFILE=test/fixtures/environment_procfile ./shoreman.sh; :)
  echo "$output" | grep -q "FOO = bar"
}

it_supports_dot_env_file() {
  cd "test/fixtures"
  output=$(PROCFILE=env_file_procfile ../../shoreman.sh; :)
  echo "$output" | grep -q "BAZ = baz"
}

it_can_pass_env_file_as_env_file() {
  output=$(PROCFILE=test/fixtures/env_file_arg_procfile ENV_FILE=test/fixtures/env_file_arg ./shoreman.sh; :)
  echo "$output" | grep -q "MUZ = bar"
}

it_ignores_comments_in_env_file() {
  cd "test/fixtures"
  output=$(PROCFILE=commented_environment_procfile ENV_FILE=env_file_with_comments ../../shoreman.sh; :)
  echo "$output" | grep -q "42 does not contain: bar"
}

it_assigns_a_default_port_number() {
  output=$(PROCFILE=test/fixtures/port_number_procfile ./shoreman.sh; :)
  echo "$output" | grep -q "5000"
}

it_allows_overriding_the_port_number() {
  output=$(PROCFILE=test/fixtures/port_number_procfile PORT=5555 ./shoreman.sh; :)
  echo "$output" | grep -q "5555"
}

it_allows_tabs_in_procfile() {
  output=$(PROCFILE=test/fixtures/tabs_procfile ./shoreman.sh; :)
  echo "$output"
  not_found='command not found'
  test "${output#*$not_found}" == "$output"
}
