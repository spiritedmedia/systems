echo "Starting Deploy..."
git config --global user.name "CircleCI"
git config --global user.email "systems@spiritedmedia.com"

cd /home/ubuntu/ci-test
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

git clone git@github.com:spiritedmedia/ci-test-build.git tmp/
mv tmp/.git .
rm -rf tmp/
git add -A
git commit -m "Build #$CIRCLE_BUILD_NUM by $CIRCLE_USERNAME on $TIMESTAMP"
git push origin master --force

echo "Code changes pushed!"
