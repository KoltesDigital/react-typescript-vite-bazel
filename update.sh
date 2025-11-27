#!/usr/bin/env bash
branch=$(git rev-parse --abbrev-ref HEAD)

git checkout main

for i in $(git branch --format='%(refname:short)'| grep -v main)
do
	git rebase "$i^" "$i" --onto main
	if [ $? -ne 0 ]
	then
		echo 'Rebase failed' >&2
		exit 1
	fi

	bazel test //...
	if [ $? -ne 0 ]
	then
		echo 'Tests failed' >&2
		exit 1
	fi
done

git checkout $branch
