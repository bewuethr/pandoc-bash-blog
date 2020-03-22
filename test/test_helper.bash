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
	if [[ ! -e /usr/local/include/pbb/pbb.css ]]; then
		sudo mkdir -p /usr/local/include/pbb
		sudo cp "$BATS_TEST_DIRNAME/../pbb.css" /usr/local/include/pbb
	fi
}

teardown() {
	rm -rf /tmp/pbb-testdata
}
