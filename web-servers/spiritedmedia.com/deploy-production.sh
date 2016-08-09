#!/bin/bash
# Shell script to update the app level with the latest changes from GitHub (ex. when called form AWS CodeDeploy)
# Should be placed in /var/www/spiritedmedia.com/scripts/ and run as root

cd /var/www/spiritedmedia.com/htdocs/

# Force git pull
git fetch --all
git reset --hard origin/master

# Reset file ownership
chown -R www-data:www-data /var/www/spiritedmedia.com/htdocs/

# Restart Nginx and PHP7 for good measure
ee stack restart --nginx --php7

# Flush permalinks
wp rewrite flush --allow-root
