#!/usr/bin/env bats

load test_helper

@test "Build post with dot graph code block" {
	pbb init "Testblog"

	cat <<- 'EOF' > ????-??-??-*.md
		# My first post

		```dot
		digraph G {
		    a -> b
		}
		```
	EOF

	run pbb build

	echo "$output"
	((status == 0))

	# Graph output file exists
	ls artifacts/diagrams
	shopt -s nullglob
	f=(artifacts/diagrams/*.svg)
	((${#f[@]} == 1))

	# Post contains image tag
	cat artifacts/????-??-??-*.html
	grep -Eq '<img src="diagrams/.{7}\.svg" />' artifacts/????-??-??-*.html
}

@test "Build post with dot graph code block and caption" {
	pbb init "Testblog"

	cat <<- 'EOF' > ????-??-??-*.md
		# My first post

		``` {.dot caption="A caption"}
		digraph G {
		    a -> b
		}
		```
	EOF

	run pbb build

	echo "$output"
	((status == 0))

	# Graph output file exists
	ls artifacts/diagrams
	shopt -s nullglob
	f=(artifacts/diagrams/*.svg)
	((${#f[@]} == 1))

	# Post contains figure and caption
	cat artifacts/????-??-??-*.html
	grep -Fq '<figure>' artifacts/????-??-??-*.html
	grep -Pzq '<img src="diagrams/.{7}\.svg" alt="A caption" />\s*<figcaption[^>]*>A caption</figcaption>' \
		artifacts/????-??-??-*.html
	grep -Fq '</figure>' artifacts/????-??-??-*.html
}

@test "Build post with dot graph code block and source included" {
	pbb init "Testblog"

	cat <<- 'EOF' > ????-??-??-*.md
		# My first post

		``` {.dot .includeSource}
		digraph G {
		    a -> b
		}
		```
	EOF

	run pbb build

	echo "$output"
	((status == 0))

	# Graph output file exists
	ls artifacts/diagrams
	shopt -s nullglob
	f=(artifacts/diagrams/*.svg)
	((${#f[@]} == 1))

	# Post contains image
	cat artifacts/????-??-??-*.html
	grep -Eq '<img src="diagrams/.{7}\.svg" />' artifacts/????-??-??-*.html

	# Post contains comment with dot source
	grep -Pz '<!--\ndigraph G \{\n    a -> b\n\}\n-->' artifacts/????-??-??-*.html
}

@test "Build post with dot graph with an error" {
	pbb init "Testblog"

	cat <<- 'EOF' > ????-??-??-*.md
		# My first post

		```dot
		digraph G {
		    a - b
		}
		```
	EOF

	run pbb build

	echo "$output"
	((status == 1))
	[[ $output == *'dot graph generation failed'* ]]
	[[ $output == *'error while converting '????-??-??'-my-first-post.md'* ]]
}
