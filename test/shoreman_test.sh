describe "Shoreman"

it_displays_usage() {
  usage=$(bash ./shoreman.sh --help | head -n1)
  test "$usage" = "Usage: shoreman [<procfile>]"
}

it_runs_simple_processes() {
  output=$(bash ./shoreman.sh 'test/fixtures/simple_procfile'; :)
  echo "$output" | grep -q "Hello"
}

it_passes_environment_variables_to_processes() {
  output=$(FOO=bar bash ./shoreman.sh 'test/fixtures/environment_procfile'; :)
  echo "$output" | grep -q "FOO = bar"
}

it_supports_dot_env_file() {
  cd "test/fixtures"
  output=$(bash ../../shoreman.sh 'env_file_procfile'; :)
  echo "$output" | grep -q "BAZ = baz"
}

it_can_pass_env_file_as_second_argument() {
  output=$(bash ./shoreman.sh 'test/fixtures/env_file_arg_procfile' 'test/fixtures/env_file_arg'; :)
  echo "$output" | grep -q "MUZ = bar"
}

it_ignores_comments_in_env_file() {
  cd "test/fixtures"
  output=$(bash ../../shoreman.sh 'simple_procfile' 'env_file_with_comments'; :)
  echo "$output" | grep -q "Hello"
}

it_passes_default_port_number() {
  output=$(bash ./shoreman.sh 'test/fixtures/port_procfile'; :)
  echo "$output" | grep -q "PORT 5000"
}

it_allows_overriding_port_number() {
  output=$(bash ./shoreman.sh 'test/fixtures/port_procfile' 'test/fixtures/port_env_file'; :)
  echo "$output" | grep -q "PORT 9292"
}

