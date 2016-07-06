#!/bin/bash
sudo goaccess -f /var/www/staging.spiritedmedia.com/logs/access.log -o /var/www/staging.spiritedmedia.com/htdocs/stats/index.html

echo "Visit http://staging.spiritedmedia.com/stats/ to view the access.log stats"
