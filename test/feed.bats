#!/usr/bin/env bats

load test_helper

@test "Building creates an Atom feed" {
	pbb init 'Testblog'
	pbb build

	# File exists
	[[ -s docs/feed.xml ]]

	# File is well-formed
	yq docs/feed.xml > /dev/null

	# Feed has one entry
	yq -o=yaml docs/feed.xml
	run yq '.feed | has("entry")' docs/feed.xml
	echo "$output"
	[[ $output == 'true' ]]
}

@test "Feed-specific properties are set correctly" {
	pbb init 'Testblog'
	pbb set authorname 'Grace Hopper'
	pbb set authoremail 'grace@example.com'
	pbb set baseurl 'https://graceblogs.com'
	pbb build

	[[ $(yq '.feed.title' docs/feed.xml) == 'Testblog' ]]
	[[ $(yq '.feed.author.name' docs/feed.xml) == 'Grace Hopper' ]]
	[[ $(yq '.feed.author.email' docs/feed.xml) == 'grace@example.com' ]]
	[[ $(yq '.feed.author.uri' docs/feed.xml) == 'https://graceblogs.com/' ]]
}

@test "Post header has a link to the Atom feed" {
	pbb init 'Testblog'
	pbb build

	cat docs/????-??-??-*.html
	grep -Fq '<link href="/feed.xml" type="application/atom+xml" rel="alternate" title="Testblog Feed">' \
		docs/????-??-??-*.html
}
