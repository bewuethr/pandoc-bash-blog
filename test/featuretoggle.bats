load test_helper

@test "Turn feature on" {
	pbb init "Testblog"
	run pbb enable math

	echo "$output"
	((status == 0))

	# Conf file contains feature
	grep -Fqx 'math=on' .pbbconfig
}

@test "Turn feature off" {
	cd /tmp/pbb-testdata
	pbb init "Testblog"
	run pbb disable bibliography

	echo "$output"
	((status == 0))

	# Conf file contains feature set to "off"
	grep -Fqx 'bibliography=off' .pbbconfig
}

@test "Complain about missing feature to enable" {
	cd /tmp/pbb-testdata
	pbb init "Testblog"
	run pbb enable

	echo "$output"
	((status == 1))

	[[ $output == 'usage: pbb enable FEATURE' ]]
}

@test "Complain about missing feature to disable" {
	cd /tmp/pbb-testdata
	pbb init "Testblog"
	run pbb disable

	echo "$output"
	((status == 1))

	[[ $output == 'usage: pbb disable FEATURE' ]]
}

@test "Complain about invalid feature to enable" {
	cd /tmp/pbb-testdata
	pbb init "Testblog"
	run pbb enable foo

	echo "$output"
	((status == 1))

	[[ $output == 'invalid feature: foo' ]]
}

@test "Complain about invalid feature to disable" {
	cd /tmp/pbb-testdata
	pbb init "Testblog"
	run pbb disable foo

	echo "$output"
	((status == 1))

	[[ $output == 'invalid feature: foo' ]]
}
