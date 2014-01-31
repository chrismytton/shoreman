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

it_supports_dot_env_file() {
  cd "test/fixtures"
  output=$(bash ../../shoreman.sh 'env_file_procfile' | head -n1)
  test "$output" = "BAZ = baz"
}

it_can_pass_env_file_as_second_argument() {
  output=$(bash ./shoreman.sh 'test/fixtures/env_file_arg_procfile' 'test/fixtures/env_file_arg' | head -n1)
  test "$output" = "MUZ = bar"
}

it_ignores_comments_in_env_file() {
  cd "test/fixtures"
  output=$(bash ../../shoreman.sh 'simple_procfile' 'env_file_with_comments' | head -n1)
  test "$output" = "Hello"
}
