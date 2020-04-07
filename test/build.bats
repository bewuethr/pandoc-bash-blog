#!/usr/bin/env bats

load test_helper

@test "Run build" {
	cd /tmp/pbb-testdata
	pbb init 'Testblog'

	run pbb build

	echo "$output"
	((status == 0))

	echo "artifacts:"
	ls artifacts

	# Check new directories
	[[ -d artifacts ]]
	[[ -d artifacts/images ]]

	# Index and post file
	[[ -f artifacts/index.html ]]
	posts=(artifacts/????-??-??-my-first-post.html)
	((${#posts[@]} == 1))

	# Stylesheet
	[[ -f artifacts/pbb.css ]]

	# Index Markdown file is cleaned up
	[[ ! -f index.md ]]
}

@test "Build post with TOC" {
	cd /tmp/pbb-testdata
	pbb init 'Testblog'
	sed -i '1i ---\ntoc: true\n...\n' *.md
	run pbb build

	echo "$output"
	((status == 0))

	# Generated post has table of contents header
	grep -Fq 'nav id="TOC" role="doc-toc">' artifacts/*-my-first-post.html
	grep -q '<h2.*>Table of contents</h2>' artifacts/*-my-first-post.html
}

@test "Build with favicon from PNG" {
	cd /tmp/pbb-testdata
	pbb init 'Testblog'
	cp "$BATS_TEST_DIRNAME/testdata/favicon.png" assets
	run pbb build

	echo "$output"
	((status == 0))

	# Check favicon file and image format
	[[ -f artifacts/favicon.png ]]
	[[ $(identify -format '%m %h %w' artifacts/favicon.png) == 'PNG 32 32' ]]

	# Check all HTML files contain favicon link in header
	for f in artifacts/*.html; do
		echo "Checking $f"
		grep -Fq '<link rel="icon" href="/favicon.png"' "$f"
	done
}

@test "Build with favicon from JPG" {
	cd /tmp/pbb-testdata
	pbb init 'Testblog'
	cp "$BATS_TEST_DIRNAME/testdata/favicon.jpg" assets
	run pbb build

	echo "$output"
	((status == 0))

	# Check favicon file and image format
	[[ -f artifacts/favicon.png ]]
	[[ $(identify -format '%m %h %w' artifacts/favicon.png) == 'PNG 32 32' ]]
}

@test "Build with favicon from GIF with multiple frames" {
	cd /tmp/pbb-testdata
	pbb init 'Testblog'
	cp "$BATS_TEST_DIRNAME/testdata/favicon.gif" assets
	run pbb build

	echo "$output"
	((status == 0))

	# Check favicon file and image format
	[[ -f artifacts/favicon.png ]]
	[[ $(identify -format '%m %h %w' artifacts/favicon.png) == 'PNG 32 32' ]]
}

@test "Warn about missing favicon" {
	cd /tmp/pbb-testdata
	pbb init 'Testblog'
	run pbb build

	echo "$output"
	((status == 0))

	[[ $output == *'found no favicon image'* ]]
}

@test "Warn about multiple favicon images" {
	cd /tmp/pbb-testdata
	pbb init 'Testblog'
	cp "$BATS_TEST_DIRNAME"/testdata/favicon.* assets
	run pbb build

	echo "$output"
	((status == 0))

	[[ $output == *'found more than one favicon image'* ]]
}
