load test_helper

@test "Run build" {
	pbb init 'Testblog'

	run pbb build

	echo "$output"
	((status == 0))

	echo "docs:"
	ls docs

	# Check new directories
	[[ -d docs ]]
	[[ -d docs/images ]]
	[[ -d docs/diagrams ]]

	# Index and post file
	[[ -f docs/index.html ]]
	posts=(docs/????-??-??-my-first-post.html)
	((${#posts[@]} == 1))

	# Stylesheet
	[[ -f docs/pbb.css ]]

	# Calendar icon
	[[ -f docs/images/calendar.svg ]]

	# Index Markdown file is cleaned up
	[[ ! -f index.md ]]
}

@test "Build post with TOC" {
	pbb init 'Testblog'
	sed -i '1i ---\ntoc: true\n...\n' ./*.md
	run pbb build

	echo "$output"
	((status == 0))

	# Generated post has table of contents header
	grep -Fq 'nav id="TOC" role="doc-toc">' docs/*-my-first-post.html
	grep -q '<h2.*>Table of contents</h2>' docs/*-my-first-post.html
}

@test "Build with favicon from PNG" {
	pbb init 'Testblog'
	cp "$BATS_TEST_DIRNAME/testdata/favicon.png" assets
	run pbb build

	echo "$output"
	((status == 0))

	# Check favicon file and image format
	[[ -f docs/favicon.png ]]
	[[ $(identify -format '%m %h %w' docs/favicon.png) == 'PNG 32 32' ]]

	# Check all HTML files contain favicon link in header
	for f in docs/*.html; do
		echo "Checking $f"
		grep -Fq '<link rel="icon" href="/favicon.png"' "$f"
	done
}

@test "Build with favicon from JPG" {
	pbb init 'Testblog'
	cp "$BATS_TEST_DIRNAME/testdata/favicon.jpg" assets
	run pbb build

	echo "$output"
	((status == 0))

	# Check favicon file and image format
	[[ -f docs/favicon.png ]]
	[[ $(identify -format '%m %h %w' docs/favicon.png) == 'PNG 32 32' ]]
}

@test "Build with favicon from GIF with multiple frames" {
	pbb init 'Testblog'
	cp "$BATS_TEST_DIRNAME/testdata/favicon.gif" assets
	run pbb build

	echo "$output"
	((status == 0))

	# Check favicon file and image format
	[[ -f docs/favicon.png ]]
	[[ $(identify -format '%m %h %w' docs/favicon.png) == 'PNG 32 32' ]]
}

@test "Warn about missing favicon" {
	pbb init 'Testblog'
	run pbb build

	echo "$output"
	((status == 0))

	[[ $output == *'found no favicon image'* ]]
}

@test "Warn about multiple favicon images" {
	pbb init 'Testblog'
	cp "$BATS_TEST_DIRNAME"/testdata/favicon.* assets
	run pbb build

	echo "$output"
	((status == 0))

	[[ $output == *'found more than one favicon image'* ]]
}
