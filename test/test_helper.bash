setup() {
	cd "$BATS_TEST_DIRNAME" || exit
	mkdir testdata
	cd testdata || exit
	git init --quiet
	# TODO pbb installer to take care of CSS symlink
}

teardown() {
	rm -rf "$BATS_TEST_DIRNAME/testdata"
}
