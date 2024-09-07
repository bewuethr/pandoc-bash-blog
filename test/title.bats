load test_helper

@test "Complain about title without title" {
	run pbb set title
	((status == 1))
	want="usage: pbb set PROPERTY VALUE"
	printf '%s\n%s\n' "got: $output" "want: $want"
	[[ $output == *$want* ]]
}

@test "Change to simple title" {
	pbb init 'Testblog'
	run pbb set title 'New Title'

	echo "$output"
	((status == 0))

	# Conf file contains new title
	grep -Fqx 'blogtitle=New\ Title' .pbbconfig

	# Header file contains title
	[[ $(< includes/header.html) == '<div id="blogtitle"><a href="./">New Title</a></div>' ]]
}

@test "Change to title with quotes" {
	pbb init 'Testblog'
	run pbb set title "Example Man's \"Blog\""

	echo "$output"
	((status == 0))

	# Conf file contains new title
	cat .pbbconfig
	grep -Fqx "blogtitle=Example\ Man\'s"'\ \"Blog\"' .pbbconfig

	# Header file contains title
	cat includes/header.html
	grep -q 'Example Man.s.*Blog' includes/header.html
}

@test "Change title without quoting parameters" {
	pbb init 'Testblog'
	run pbb set title New Title without Quotes

	echo "$output"
	((status == 0))

	# Conf file contains new title
	grep -Fqx 'blogtitle=New\ Title\ without\ Quotes' .pbbconfig

	# Header file contains title
	[[ $(< includes/header.html) == '<div id="blogtitle"><a href="./">New Title without Quotes</a></div>' ]]
}
