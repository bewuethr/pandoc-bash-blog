#!/usr/bin/env bats

load test_helper

@test "Blog built with MathJax includes it" {
	pbb init "Testblog"
	pbb enable math
	printf '%s\n' '$1 + 1$' >> ????-??-??-*.md
	run pbb build

	echo "$output"
	((status == 0))

	# Post contains MathJax include
	cat artifacts/????-??-??-*.html
	grep -q '<script src=".*mathjax.*js" type="text/javascript"></script>' artifacts/????-??-??-*.html
}

@test "Blog built after disabling MathJax does not include it" {
	pbb init "Testblog"
	pbb enable math
	printf '%s\n' '$1 + 1$' >> ????-??-??-*.md
	pbb build
	pbb disable math
	run pbb build

	echo "$output"
	((status == 0))

	# Post does not contain MathJax include
	cat artifacts/????-??-??-*.html
	! grep -q '<script src=".*mathjax.*js" type="text/javascript"></script>' artifacts/????-??-??-*.html
}
