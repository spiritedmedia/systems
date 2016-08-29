#!/bin/bash
# Shell script to update the app level with the latest changes from GitHub (ex. when called form AWS CodeDeploy)
# Should be placed in /var/www/spiritedmedia.com/scripts/ and run as root

cd /var/www/spiritedmedia.com/htdocs/

# Force git pull
git fetch --all
git reset --hard origin/master

# Reset file ownership
chown -R www-data:www-data /var/www/spiritedmedia.com/htdocs/

# Sync static theme files to S3 so they can be served through a CDN
s3cmd sync --acl-public --exclude-from /var/www/spiritedmedia.com/scripts/sync.exclude --include-from /var/www/spiritedmedia.com/scripts/sync.include /var/www/spiritedmedia.com/htdocs/wp-content/ s3://spiritedmedia-com/wp-content/

# Flush Redis Cache
redis-cli -h redis.spiritedmedia.com flushall

# Restart Nginx and PHP7 for good measure
ee stack restart --nginx --php7

# Flush permalinks
wp rewrite flush --allow-root
