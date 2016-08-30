#!/bin/bash
echo "Starting Deploy..."
git config --global user.name "CircleCI"
git config --global user.email "systems@spiritedmedia.com"

cd /home/ubuntu/$CIRCLE_PROJECT_REPONAME # <-- Change this to match the name of the repo we're building

TIMESTAMP=$(date +"%Y-%m-%d %I:%M %p %Z")

# Make a new README.md with build status details
rm README.md
cat > README.md <<EOF
Build [#$CIRCLE_BUILD_NUM]($CIRCLE_BUILD_URL) by $CIRCLE_USERNAME at $TIMESTAMP

[$CIRCLE_COMPARE_URL]($CIRCLE_COMPARE_URL)
EOF

# If a Git tag is being built then include a change log in the README.md file
if [[ $CIRCLE_TAG ]]; then

	# Get a list of all tags in reverse order
	# Assumes the tags are in version format like v1.2.3
	GIT_TAGS=$(git tag -l --sort=-version:refname)

	# Make the tags an array
	TAGS=($GIT_TAGS)
	LATEST_TAG=${TAGS[0]}
	PREVIOUS_TAG=${TAGS[1]}

	# Get a log of commits that occured between two tags
	# We only get the commit hash so we don't have to deal with a bunch of ugly parsing
	# See Pretty format placeholders at https://git-scm.com/docs/pretty-formats
	COMMITS=$(git log $PREVIOUS_TAG..$LATEST_TAG --pretty=format:"%H")

	# Store our changelog in a variable to be saved to a file at the end
	MARKDOWN="## Change log"
	MARKDOWN+='\n'
	MARKDOWN+="[Full Changelog]($CIRCLE_REPOSITORY_URL/compare/$PREVIOUS_TAG...$LATEST_TAG)"
	MARKDOWN+='\n'
	# Loop over each commit looking for merged pull requests.
	for COMMIT in $COMMITS; do
		# Get the subject of the current commit
		SUBJECT=$(git log -1 ${COMMIT} --pretty=format:"%s")

		# If the subject contains "Merge pull request #xxxxx" then it is deemed a pull request
		PULL_REQUEST=$( grep -Eo "Merge pull request #[[:digit:]]+" <<< "$SUBJECT" )
		if [[ $PULL_REQUEST ]]; then
			# Perform a substring operation so we're left with just the digits of the pull request
			PULL_NUM=${PULL_REQUEST#"Merge pull request #"}

			#Get the body of the commit
			BODY=$(git log -1 ${COMMIT} --pretty=format:"%b")
			MARKDOWN+='\n'
			MARKDOWN+=" - [#$PULL_NUM]($CIRCLE_REPOSITORY_URL/pull/$PULL_NUM): $BODY"
		fi
	done

	# Save our markdown to a file
	echo -e $MARKDOWN >> README.md

fi

# This should be ignored in .gitignore-build but let's try and remove it just to be safe
rm -rf node_modules/
# Find all .git/ directories and remove them. If we commit directories with .git in them then they are treated like sub-modules and screw that.
find . | grep -w ".git" | xargs rm -rf
# Remove all .gitignore files in the wp-content/ and vendor/ directories
find wp-content/ vendor/ -name ".gitignore" | xargs rm

rm .gitignore
mv .gitignore-build .gitignore

git clone git@github.com:spiritedmedia/spiritedmedia-build.git tmp/
mv tmp/.git .
rm -rf tmp/

# If no branch is set then assume master
if [ ! $CIRCLE_BRANCH  ]; then
	CIRCLE_BRANCH="master"
fi

# Switch branches... maybe?
if [ ! `git branch --list $CIRCLE_BRANCH` ]; then
	# Branch doesn't exist. Create it and check it out. See http://stackoverflow.com/a/21151276
	git checkout -b $CIRCLE_BRANCH
else
	git checkout $CIRCLE_BRANCH
fi

# Add everything and commit
git add -A
git commit -m "Build #$CIRCLE_BUILD_NUM by $CIRCLE_USERNAME on $TIMESTAMP"
git push origin $CIRCLE_BRANCH --force

echo "Code changes pushed!"
