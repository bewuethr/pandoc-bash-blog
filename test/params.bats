#!/usr/bin/env bats

@test "Complain about no subcommand" {
	run pbb
	((status == 1))
	want=(
		'usage:'
		'pbb help'
		'pbb enable'
	)
	printf '%s\n%s\n' "got: $output" "want: $want"
	for ((i = 0; i < ${#want[@]}; ++i)); do
		[[ ${lines[i]} == "${want[i]}"* ]]
	done
}

@test "Help output" {
	run pbb help
	((status == 0))
	want=(
		'usage:'
		'pbb help'
		'pbb enable'
	)
	printf '%s\n%s\n' "got: $output" "want: $want"
	for ((i = 0; i < ${#want[@]}; ++i)); do
		[[ ${lines[i]} == "${want[i]}"* ]]
	done
}

@test "Complain about non-existent subcommand" {
	run pbb foo
	((status == 1))
	want=(
		'usage:'
		'pbb help'
		'pbb enable'
	)
	printf '%s\n%s\n' "got: $output" "want: $want"
	for ((i = 0; i < ${#want[@]}; ++i)); do
		[[ ${lines[i]} == "${want[i]}"* ]]
	done
}
