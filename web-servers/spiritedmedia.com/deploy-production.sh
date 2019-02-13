#!/bin/bash
# Shell script to update the app level with the latest changes from GitHub (ex. when called form AWS CodeDeploy)
# Should be placed in /var/www/spiritedmedia.com/scripts/ and run as root

cd /var/www/spiritedmedia.com/htdocs/

# Force git pull
git fetch --all
git reset --hard origin/master

# Reset file ownership
chown -R www-data:www-data /var/www/spiritedmedia.com/htdocs/

# Sync static files to S3 so they can be served through a CDN
# Helpful article: https://www.lambrospetrou.com/articles/aws-s3-sync-git-status/

# General args go here
AWS_SYNC_ARGS=(
  # --dryrun
  --acl public-read
  --storage-class REDUCED_REDUNDANCY
)

# File types and locations to be excluded from sync
AWS_EXCLUDE=(
  '*'
  'composer.json'
  '.git/*'
)

# File types and locations to be included from sync
AWS_INCLUDE=(
  # CSS/JavaScript
  '*.css'
  '*.js'
  '*.json'

  # Images
  '*.png'
  '*.jpg'
  '*.jpeg'
  '*.bmp'
  '*.gif'
  '*.ico'
  '*.svg'

  # Fonts
  '*.woff2'
  '*.woff'
  '*.ttf'
  '*.otf'

  # Other
  '*.pdf'
  '*.xml'
)
for i in "${AWS_EXCLUDE[@]}"; do
  AWS_SYNC_ARGS+=('--exclude="'$i'"')
done

for i in "${AWS_INCLUDE[@]}"; do
  AWS_SYNC_ARGS+=('--include="'$i'"')
done

# echo "${AWS_SYNC_ARGS[@]}"

echo "=== SYNCING THEMES DIRECTORY ==="
echo "${AWS_SYNC_ARGS[@]}" | xargs aws s3 sync /var/www/spiritedmedia.com/htdocs/wp-content/themes/ s3://spiritedmedia-com/wp-content/themes/

echo "=== SYNCING PLUGINS DIRECTORY ==="
echo "${AWS_SYNC_ARGS[@]}" | xargs aws s3 sync /var/www/spiritedmedia.com/htdocs/wp-content/plugins/ s3://spiritedmedia-com/wp-content/plugins/

echo "=== SYNCING MU-PLUGINS DIRECTORY ==="
echo "${AWS_SYNC_ARGS[@]}" | xargs aws s3 sync /var/www/spiritedmedia.com/htdocs/wp-content/mu-plugins/ s3://spiritedmedia-com/wp-content/mu-plugins/

echo "=== SYNCING WP-ADMIN DIRECTORY ==="
echo "${AWS_SYNC_ARGS[@]}" | xargs aws s3 sync /var/www/spiritedmedia.com/htdocs/wp-admin/ s3://spiritedmedia-com/wp-admin/

echo "=== SYNCING WP-ADMIN DIRECTORY ==="
echo "${AWS_SYNC_ARGS[@]}" | xargs aws s3 sync /var/www/spiritedmedia.com/htdocs/wp-includes/ s3://spiritedmedia-com/wp-includes/

# Flush Redis Cache
redis-cli -h redis.spiritedmedia.com flushall

# Restart Nginx and PHP7 for good measure
ee stack restart --nginx --php7

# Flush permalinks
for url in $(wp site list --allow-root --field=url)
do
  echo $url #Used for progress purposes
  wp rewrite flush --allow-root --url=$url
done
