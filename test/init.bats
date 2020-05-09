#!/usr/bin/env bats

load test_helper

@test "Complain about init without title" {
	run pbb init
	((status == 1))
	want="usage: pbb init TITLE"
	printf '%s\n%s\n' "got: $output" "want: $want"
	[[ $output == *$want* ]]
}

@test "Run init with simple title" {
	run pbb init 'Testblog'

	echo "$output"
	((status == 0))

	# Git branch is "source"
	[[ $(git symbolic-ref -q --short HEAD) == 'source' ]]

	# Directories assets, images and includes exist
	[[ -d assets ]]
	[[ -d images ]]
	[[ -d includes ]]

	# Conf file contains title
	grep -Fqx 'blogtitle=Testblog' .pbbconfig

	# Metadata file contains TOC settings
	grep -Fqx 'toc: false' .metadata.yml
	grep -Fqx 'toc-title: Table of contents' .metadata.yml

	# Header file contains title
	[[ $(< includes/header.html) == '<p><a href="./">Testblog</a></p>' ]]

	# CSS file is symlinked
	[[ -L assets/pbb.css ]]

	# Font links file exists
	fontlinks='includes/fontlinks.html'
	[[ -s $fontlinks ]]
	grep -Fq 'https://fonts.gstatic.com' "$fontlinks"
	grep -Fq 'https://fonts.googleapis.com' "$fontlinks"

	# Favicon header include exists
	favicon='includes/favicon.html'
	[[ -s $favicon ]]
	grep -Fq 'href="/favicon.png"' "$favicon"

	# Git history has one entry
	[[ $(git log --oneline) == *'Initialize blog with pbb' ]]

	# Example post exists
	printf -v fname '%(%F)T-my-first-post.md' -1
	[[ -s $fname ]]
	grep -Fq '# My first post' "$fname"
}

@test "Run init with title containing quotes and blank" {
	run pbb init "Bashman's \"Blog\""

	echo "$output"
	((status == 0))

	# Conf file contains title
	grep -Fqx "blogtitle=Bashman\'"'s\ \"Blog\"' .pbbconfig

	# Header file contains title
	cat includes/header.html
	grep -q 'Bashman.s.*Blog' includes/header.html
}

@test "Run init twice" {
	run pbb init "Testblog"
	run pbb init "Testblog"

	echo "$output"
	((status == 1))
	[[ $output == *'Could not create new branch'* ]]
}

@test "Run init in initalized non-Git directory" {
	pbb init "Testblog"
	rm -rf .git
	setup
	run pbb init "Testblog"

	echo "$output"
	((status == 1))
	[[ $output == *'Conf file exists already'* ]]
}
