load test_helper

@test "Run deploy" {
	pbb init 'Testblog'
	pbb build
	git push --set-upstream origin "$(git branch --show-current)"
	run pbb deploy

	echo "$output"

	((status == 0))

	# There are two commits
	git log --oneline
	(($(git rev-list --count HEAD) == 2))

	# Check commit message
	git log --pretty='format:%s' -1
	[[ $(git log --pretty='format:%s' -1) == 'Publish blog' ]]
}

@test "Run deploy with missing docs directory" {
	pbb init 'Testblog'
	run pbb deploy

	echo "$output"

	((status == 1))
	[[ $output == *"can't find index file"* ]]
}
