#! /bin/bash

# Clean-up challenge directories
sudo rm -rf /var/www/staging.spiritedmedia.com/htdocs/.well-known/acme-challenge

# Run Lets Encrpyt
/opt/letsencrypt/letsencrypt-auto certonly --webroot -w /var/www/staging.spiritedmedia.com/htdocs/ -d staging.spiritedmedia.com -d staging.billypenn.com -d staging.theincline.com -d staging.denverite.com --email systems@spiritedmedia.com --text --agree-tos

# Restart Nginx
sudo ee stack reload --nginx
