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

	# Directories assets, images and includes exist
	[[ -d assets ]]
	[[ -d images ]]
	[[ -d includes ]]

	# Conf file contains title
	grep -Fqx 'blogtitle=Testblog' .pbbconfig

	# Metadata file contains TOC and bibliography settings
	grep -Fqx 'toc: false' .metadata.yml
	grep -Fqx 'toc-title: Table of contents' .metadata.yml
	grep -Fqx 'reference-section-title: Bibliography' .metadata.yml

	# Header file contains title
	[[ $(< includes/header.html) == '<div id="blogtitle"><a href="./">Testblog</a></div>' ]]

	# Assets are symlinked
	ls assets
	[[ -L assets/pbb.css ]]
	[[ -L assets/calendar.svg ]]

	# Header links file exists
	headerlinks='includes/headerlinks.html'
	[[ -s $headerlinks ]]
	grep -Fq 'https://fonts.gstatic.com' "$headerlinks"
	grep -Fq 'https://fonts.googleapis.com' "$headerlinks"

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
	[[ $output == 'conf file exists already'* ]]
}

@test "Run init in initalized non-Git directory" {
	pbb init "Testblog"
	rm -rf .git
	setup
	run pbb init "Testblog"

	echo "$output"
	((status == 1))
	[[ $output == 'conf file exists already'* ]]
}

@test "Run init in non-Git directory" {
	rm -rf .git
	run pbb init "Testblog"

	echo "$output"
	((status == 1))
	[[ $output == 'not in a git repo'* ]]
}

@test "Run init not in root of repo" {
	mkdir subdir
	cd subdir
	run pbb init "Testblog"

	echo "$output"
	((status == 1))
	[[ $output == 'in git repo, but not in root directory'* ]]
}
