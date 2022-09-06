#!/usr/bin/env bats

load test_helper

@test "Blog built with bibliography includes it" {
	pbb init "Testblog"
	cp "$BATS_TEST_DIRNAME/testdata/bibliography.yaml" assets
	pbb enable bibliography

	cat <<- 'EOF' > ????-??-??-*.md
		---
		bibliography: assets/bibliography.yaml
		...

		# My first post

		Blah blah [@Ritchie1974].
	EOF

	run pbb build

	echo "$output"
	((status == 0))

	# Post contains reference
	cat artifacts/????-??-??-*.html
	grep -Pqz 'data-cites="Ritchie1974">\(Ritchie\sand\sThompson\s1974\)' artifacts/????-??-??-*.html

	# Post contains bibliography
	grep -q 'id="bibliography".*>Bibliography</h1>' artifacts/????-??-??-*.html
}
