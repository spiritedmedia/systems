#!/bin/bash
# Shell script to update the app level with the latest changes from GitHub (ex. when called form AWS CodeDeploy)
# Should be placed in /var/www/staging.spiritedmedia.com/scripts/ and run as root

cd /var/www/staging.spiritedmedia.com/htdocs/

# Force git pull
git fetch --all
git reset --hard origin/staging

# Reset file ownership
echo 'Reset File Permissions'
chown -R www-data:www-data /var/www/staging.spiritedmedia.com/htdocs/wp-content/

# Flush Redis Cache
redis-cli flushall

# Restart Nginx and PHP7 for good measure
ee stack restart --nginx --php7

# Flush permalinks
for url in $(wp site list --allow-root --field=url)
do
  echo $url #Used for progress purposes
  wp rewrite flush --allow-root --url=$url
done
