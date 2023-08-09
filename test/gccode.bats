#!/usr/bin/env bats

load test_helper

@test "Complain about gccode without code" {
	run pbb set gccode
	((status == 1))
	want="usage: pbb set PROPERTY VALUE"
	printf '%s\n%s\n' "got: $output" "want: $want"
	[[ $output == *$want* ]]
}

@test "Set initial GoatCounter code" {
	pbb init "Testblog"
	run pbb set gccode 'mycode'
	pbb build

	echo "$output"
	((status == 0))

	# Conf file contains code
	grep -Fqx 'goatcountercode=mycode' .pbbconfig

	# Include contains code
	cat includes/goatcounter.html
	grep -Fq 'https://mycode.goatcounter.com' includes/goatcounter.html

	# Index file includes snippet with code
	grep -Fq 'data-goatcounter="https://mycode.goatcounter.com/count' docs/index.html
}

@test "Set GoatCounter code, then change it" {
	pbb init "Testblog"
	pbb set gccode 'mycode'
	pbb build
	run pbb set gccode 'anothercode'
	pbb build

	echo "$output"
	((status == 0))

	# Conf file contains second code
	grep -Fqx 'goatcountercode=anothercode' .pbbconfig

	# Include contains second code
	cat includes/goatcounter.html
	grep -Fq 'https://anothercode.goatcounter.com' includes/goatcounter.html

	# Index file includes snippet with second code
	grep -Fq 'data-goatcounter="https://anothercode.goatcounter.com/count' docs/index.html
}

@test "Set GoatCounter code, then set it to empty" {
	pbb init "Testblog"
	pbb set gccode 'mycode'
	pbb build
	run pbb set gccode ''
	pbb build

	echo "$output"
	((status == 0))

	# Conf file contains empty entry for code
	cat .pbbconfig
	grep -Fqx "goatcountercode=''" .pbbconfig

	# Include contains no code
	cat includes/goatcounter.html
	grep -Fq 'https://.goatcounter.com' includes/goatcounter.html

	# Index file does not include snippet
	bats_require_minimum_version 1.5.0
	run ! grep -q 'data-goatcounter="https://.*\.goatcounter\.com/count' docs/index.html
}

@test "Set GoatCounter to code empty, then non-empty" {
	pbb init "Testblog"
	pbb set gccode ''
	pbb build
	run pbb set gccode 'mycode'
	pbb build

	echo "$output"
	((status == 0))

	# Conf file contains code
	grep -Fqx 'goatcountercode=mycode' .pbbconfig

	# Include contains code
	cat includes/goatcounter.html
	grep -Fq 'https://mycode.goatcounter.com' includes/goatcounter.html

	# Index file includes snippet with code
	grep -Fq 'data-goatcounter="https://mycode.goatcounter.com/count' docs/index.html
}
