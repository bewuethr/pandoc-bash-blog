setup() {
	mkdir -p /tmp/pbb-testdata
	cd /tmp/pbb-testdata || exit
	git init --quiet

	if [[ -z $(git config --get user.name) ]]; then
		git config user.name "Integration Test"
	fi
	if [[ -z $(git config --get user.email) ]]; then
		git config user.email "integration.test@example.com"
	fi
	# TODO pbb installer to take care of CSS symlink
}

teardown() {
	rm -rf /tmp/pbb-testdata
}

resetgit() {
	cd /tmp/pbb-testdata || exit
	rm -rf .git
	setup
}
