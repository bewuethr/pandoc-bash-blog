#!/usr/bin/env bats

load test_helper

@test "Run serve" {
	cd /tmp/pbb-testdata
	pbb init 'Testblog'
	pbb build
	timeout 0.7 pbb serve &
	sleep 0.4

	run curl localhost:8000

	echo "$output"

	((status == 0))
	[[ $output == *'<title>Testblog</title>'* ]]
}

@test "Run serve with missing artifacts directory" {
	cd /tmp/pbb-testdata
	pbb init 'Testblog'
	run pbb serve

	echo "$output"

	((status == 1))
	[[ $output == *"can't find artifacts directory"* ]]
}

@test "Run serve with missing index file" {
	cd /tmp/pbb-testdata
	pbb init 'Testblog'
	pbb build
	rm artifacts/index.html
	run pbb serve

	echo "$output"

	((status == 1))
	[[ $output == *"can't find index file"* ]]
}
