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
	ls docs/diagrams
	shopt -s nullglob
	f=(docs/diagrams/*.svg)
	((${#f[@]} == 1))

	# Post contains image tag
	cat docs/????-??-??-*.html
	grep -Eq '<img src="diagrams/.{7}\.svg" />' docs/????-??-??-*.html
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
	ls docs/diagrams
	shopt -s nullglob
	f=(docs/diagrams/*.svg)
	((${#f[@]} == 1))

	# Post contains figure and caption
	cat docs/????-??-??-*.html
	grep -Fq '<figure>' docs/????-??-??-*.html
	grep -Pzq '<img src="diagrams/.{7}\.svg" alt="A caption" />\s*<figcaption[^>]*>A caption</figcaption>' \
		docs/????-??-??-*.html
	grep -Fq '</figure>' docs/????-??-??-*.html
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
	ls docs/diagrams
	shopt -s nullglob
	f=(docs/diagrams/*.svg)
	((${#f[@]} == 1))

	# Post contains image
	cat docs/????-??-??-*.html
	grep -Eq '<img src="diagrams/.{7}\.svg" />' docs/????-??-??-*.html

	# Post contains comment with dot source
	grep -Pz '<!--\ndigraph G \{\n    a -> b\n\}\n-->' docs/????-??-??-*.html
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
