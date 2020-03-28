#!/usr/bin/env bats

load test_helper

@test "Run deploy" {
	cd /tmp/pbb-testdata
	pbb init 'Testblog'
	pbb build
	run pbb deploy

	echo "$output"

	((status == 0))

	# There are two commits in master
	git log --oneline master
	(($(git rev-list --count master) == 2))

	# Check commit message
	git log --pretty='format:%s' -1 master
	[[ $(git log --pretty='format:%s' -1 master) == 'Publish blog' ]]
}

@test "Run deploy with missing artifacts directory" {
	cd /tmp/pbb-testdata
	pbb init 'Testblog'
	run pbb deploy

	echo "$output"

	((status == 1))
	[[ $output == *"nothing to deploy"* ]]
}

@test "Run deploy when in master" {
	cd /tmp/pbb-testdata
	pbb init 'Testblog'
	pbb build
	git checkout -b master
	run pbb deploy

	echo "$output"

	((status == 1))
	[[ $output == *"already on master"* ]]
}
