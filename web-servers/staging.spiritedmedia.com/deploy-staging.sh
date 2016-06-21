#!/bin/bash
# Shell script to update the app level with the latest changes from GitHub (ex. when called form AWS CodeDeploy)

cd /var/www/staging.spiritedmedia.com/htdocs/

# Force git pull
git fetch --all
git reset --hard origin/staging

# Reset file ownership
chown -R www-data:www-data /var/www/staging.spiritedmedia.com/htdocs/

# Restart Nginx and PHP7 for good measure
ee stack restart --nginx --php7