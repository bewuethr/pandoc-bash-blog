setup() {
	# Set up repositories
	local remote='/tmp/pbb-remote.git'
	git init --quiet --bare "$remote"

	local repo='/tmp/pbb-testdata'
	mkdir --parents "$repo"
	git -C "$repo" init --quiet
	git -C "$repo" remote add origin "$remote"

	if [[ -z $(git -C "$repo" config --get user.name) ]]; then
		git -C "$repo" config user.name "Integration Test"
	fi
	if [[ -z $(git -C "$repo" config --get user.email) ]]; then
		git -C "$repo" config user.email "integration.test@example.com"
	fi

	if [[ ! -e ${XDG_DATA_HOME:-$HOME/.local/share}/pbb/pbb.css ]]; then
		make install
	fi
	cd /tmp/pbb-testdata || exit
}

teardown() {
	rm -rf /tmp/pbb-testdata /tmp/pbb-remote.git
}
