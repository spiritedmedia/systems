#!/bin/bash
# Shell script to update the app level with the latest changes from GitHub (ex. when called form AWS CodeDeploy)
# Should be placed in /var/www/staging.spiritedmedia.com/scripts/ and run as root

cd /var/www/staging.spiritedmedia.com/htdocs/

# Force git pull
git fetch --all
git reset --hard origin/staging

# Reset file ownership
chown -R www-data:www-data /var/www/staging.spiritedmedia.com/htdocs/

# Sync static theme files to S3 so they can be served through a CDN
s3cmd sync \
	--acl-public \
	--no-mime-magic \
	--guess-mime-type \
	--storage-class REDUCED_REDUNDANCY \
	--exclude-from /var/www/staging.spiritedmedia.com/scripts/sync.exclude \
	--include-from /var/www/staging.spiritedmedia.com/scripts/sync.include \
	/var/www/staging.spiritedmedia.com/htdocs/ s3://staging-spiritedmedia-com/

# Flush Redis Cache
redis-cli flushall

# Restart Nginx and PHP7 for good measure
ee stack restart --nginx --php7

# Flush permalinks
wp rewrite flush --allow-root
