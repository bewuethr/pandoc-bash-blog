load test_helper

@test "Emoji is included in HTML" {
	pbb init "Testblog"
	printf '%s\n' ':grimacing:' >> ????-??-??-*.md
	run pbb build

	echo "$output"
	((status == 0))

	# Post contains emoji
	cat docs/????-??-??-*.html
	grep -Pzq '<span\s+class="emoji"\s+data-emoji="grimacing">' docs/????-??-??-*.html
}
