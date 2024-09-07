load test_helper

@test "Blog built with MathJax includes it" {
	pbb init "Testblog"
	pbb enable math
	# shellcheck disable=SC2016
	printf '%s\n' '$1 + 1$' >> ????-??-??-*.md
	run pbb build

	echo "$output"
	((status == 0))

	# Post contains MathJax include
	cat docs/????-??-??-*.html
	grep -Pzq '<script\s+src=".*mathjax.*js"\s+type="text/javascript"></script>' docs/????-??-??-*.html
}

@test "Blog built after disabling MathJax does not include it" {
	pbb init "Testblog"
	pbb enable math
	# shellcheck disable=SC2016
	printf '%s\n' '$1 + 1$' >> ????-??-??-*.md
	pbb build
	pbb disable math
	run pbb build

	echo "$output"
	((status == 0))

	# Post does not contain MathJax include
	cat docs/????-??-??-*.html
	bats_require_minimum_version 1.5.0
	run ! grep -q '<script src=".*mathjax.*js" type="text/javascript"></script>' docs/????-??-??-*.html
}
