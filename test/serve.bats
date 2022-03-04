#!/usr/bin/env bats

load test_helper

@test "Run serve" {
	pbb init 'Testblog'
	pbb build
	pbb serve 3>&- &
	sleep 0.4

	run curl localhost:8000
	kill %1

	echo "$output"

	((status == 0))
	[[ $output == *'<title>Testblog</title>'* ]]
}

@test "Run serve with missing artifacts directory" {
	pbb init 'Testblog'
	run pbb serve

	echo "$output"

	((status == 1))
	[[ $output == *"can't find artifacts directory"* ]]
}

@test "Run serve with missing index file" {
	pbb init 'Testblog'
	pbb build
	rm artifacts/index.html
	run pbb serve

	echo "$output"

	((status == 1))
	[[ $output == *"can't find index file"* ]]
}

@test "Rebuild post when modified" {
	pbb init 'Testblog'
	pbb build
	pbb serve 3>&- &
	sleep 0.4

	mdnames=(*.md)
	mdname=${mdnames[0]}
	htmlname="artifacts/${mdname/%md/html}"

	# Built HTML is newer than Markdown source
	printf '%s\n' "Before" \
		"$(stat -c '%y - %n' "$mdname")" \
		"$(stat -c '%y - %n' "$htmlname")"
	[[ $htmlname -nt $mdname ]]

	# Update post to trigger rebuild
	printf '\n%s\n' "Extra text." >> "$mdname"
	sleep 0.4

	# HTML is still newer than Markdown
	printf '%s\n' "After" \
		"$(stat -c '%y - %n' "$mdname")" \
		"$(stat -c '%y - %n' "$htmlname")"
	[[ $htmlname -nt $mdname ]]

	# Rebuilt post still contains datestamp
	grep -q '<p class="date">....-..-..</p>' "$htmlname"

	kill %1
}

@test "Re-copy image when modified" {
	pbb init 'Testblog'
	cp "$BATS_TEST_DIRNAME/testdata/favicon.png" images/image.png
	pbb build
	pbb serve 3>&- &
	sleep 0.4

	srcimg=images/image.png
	destimg="artifacts/$srcimg"

	# Image in artifacts is newer than in images
	printf '%s\n' "Before" \
		"$(stat -c '%y - %n' "$srcimg")" \
		"$(stat -c '%y - %n' "$destimg")"
	[[ $destimg -nt $srcimg ]]

	# Update image to trigger fresh copy
	cp "$BATS_TEST_DIRNAME/testdata/favicon.png" images/image.png
	sleep 0.4

	# Image in artifacts is still newer than in images
	printf '%s\n' "After" \
		"$(stat -c '%y - %n' "$srcimg")" \
		"$(stat -c '%y - %n' "$destimg")"
	! [[ $destimg -ot $srcimg ]]

	kill %1
}
