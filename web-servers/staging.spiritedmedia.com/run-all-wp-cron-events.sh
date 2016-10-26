#! /bin/bash
# Use WP CLI to manage our own cron jobs
# Should be triggered by a cron job like so:
# * * * * * /var/www/staging.spiritedmedia.com/scripts/run-all-wp-cron-events.sh > /dev/null 2>&1
#
# Be sure to disable WordPress' own cron system by setting define('DISABLE_WP_CRON', true); in wp-config.php
#
# via http://wordpress.stackexchange.com/a/239257/2744

function run_all_crons_due_now { for SITE_URL in $(wp site list --fields=url --format=csv --allow-root | tail -n +2 | sort); do wp cron event run --due-now --allow-root --url="$SITE_URL" && echo -e "\t+ Finished crons for $SITE_URL" & done; wait $(jobs -p); echo "Done"; }; cd /var/www/staging.spiritedmedia.com/htdocs; run_all_crons_due_now;
