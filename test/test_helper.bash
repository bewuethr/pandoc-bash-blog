setup() {
	# Set up repositories
	local remote='/tmp/pbb-remote.git'
	git init --quiet --bare "$remote"

	local repo='/tmp/pbb-testdata'
	mkdir -p "$repo"
	git -C "$repo" init --quiet
	git -C "$repo" remote add origin "$remote"

	if [[ -z $(git -C "$repo" config --get user.name) ]]; then
		git -C "$repo" config user.name "Integration Test"
	fi
	if [[ -z $(git -C "$repo" config --get user.email) ]]; then
		git -C "$repo" config user.email "integration.test@example.com"
	fi

	if [[ ! -e /usr/local/include/pbb/pbb.css ]]; then
		sudo mkdir -p /usr/local/include/pbb
		sudo cp "$BATS_TEST_DIRNAME/../pbb.css" /usr/local/include/pbb
	fi
}

teardown() {
	rm -rf /tmp/pbb-testdata /tmp/pbb-remote.git
}
