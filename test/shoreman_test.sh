describe "Shoreman"

it_displays_usage() {
  usage=$(./shoreman.sh --help | head -n1)
  test "$usage" = "Usage: shoreman [procfile|Procfile] [envfile|.env]"
}

it_runs_simple_processes() {
  output=$(./shoreman.sh 'test/fixtures/simple_procfile'; :)
  echo "$output" | grep -q "Hello"
}

it_passes_environment_variables_to_processes() {
  output=$(FOO=bar ./shoreman.sh 'test/fixtures/environment_procfile'; :)
  echo "$output" | grep -q "FOO = bar"
}

it_supports_dot_env_file() {
  cd "test/fixtures"
  output=$(../../shoreman.sh 'env_file_procfile'; :)
  echo "$output" | grep -q "BAZ = baz"
}

it_can_pass_env_file_as_second_argument() {
  output=$(./shoreman.sh 'test/fixtures/env_file_arg_procfile' 'test/fixtures/env_file_arg'; :)
  echo "$output" | grep -q "MUZ = bar"
}

it_ignores_comments_in_env_file() {
  cd "test/fixtures"
  output=$(../../shoreman.sh 'commented_environment_procfile' 'env_file_with_comments'; :)
  echo "$output" | grep -q "42 does not contain: bar"
}

it_assigns_a_default_port_number() {
  output=$(./shoreman.sh 'test/fixtures/port_number_procfile'; :)
  echo "$output" | grep -q "5000"
}

it_allows_overriding_the_port_number() {
  output=$(PORT=5555 ./shoreman.sh 'test/fixtures/port_number_procfile'; :)
  echo "$output" | grep -q "5555"
}

it_allows_tabs_in_procfile() {
  output=$(./shoreman.sh 'test/fixtures/tabs_procfile'; :)
  echo "$output"
  not_found='command not found'
  test "${output#*$not_found}" == "$output"
}

it_is_compatible_with_foreman() {
  output=$(./shoreman.sh 'test/fixtures/foreman_compatible'; :)
  line0=$(echo "$output" | wc -l)
  line1=$(echo "$output" | grep "abc" | wc -l)
  line2=$(echo "$output" | grep "def" | wc -l)
  line3=$(echo "$output" | grep "ghi" | wc -l)
  line4=$(echo "$output" | grep "no-space_" | wc -l)
  line5=$(echo "$output" | grep "space\\\\" | wc -l)
  [ $line0 -eq 5 -a $line1 -eq 0 -a $line2 -eq 0 -a $line3 -eq 2 -a $line4 -eq 3 -a $line5 -eq 2 ]
}
