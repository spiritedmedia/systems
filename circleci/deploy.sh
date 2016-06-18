echo "Starting Deploy..."
git config --global user.name "CircleCI"
git config --global user.email "systems@spiritedmedia.com"

cd /home/ubuntu/$CIRCLE_PROJECT_REPONAME # <-- Change this to match the name of the repo we're building
# This should be ignored in .gitignore-deploy but let's try and remove it just to be safe
rm -rf node_modules/
rm -rf .git/
rm .gitignore
mv .gitignore-build .gitignore

TIMESTAMP=$(date +"%Y-%m-%d %I:%M %p %Z")
# Make a new README.md with build status details
rm README.md
cat > README.md <<EOF
Build [#$CIRCLE_BUILD_NUM]($CIRCLE_BUILD_URL) by $CIRCLE_USERNAME at $TIMESTAMP

[$CIRCLE_COMPARE_URL]($CIRCLE_COMPARE_URL)
EOF

git clone git@github.com:spiritedmedia/pedestal-beta-build.git tmp/
mv tmp/.git .
rm -rf tmp/

# Switch branches... maybe?
if [ $CIRCLE_BRANCH != "master" ]; then
	if [ ! `git branch --list $CIRCLE_BRANCH` ]; then
	   git checkout -b $CIRCLE_BRANCH
   	else
		git checkout $CIRCLE_BRANCH
	fi
fi

# Add everything and commit
git add -A
git commit -m "Build #$CIRCLE_BUILD_NUM by $CIRCLE_USERNAME on $TIMESTAMP"
git push origin $CIRCLE_BRANCH --force

echo "Code changes pushed!"
