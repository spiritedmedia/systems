#!/bin/bash
# This script will sync uploaded media stored in our S3 bucket to the server. Use this if you need to pull down uploads from the cloud.
# Requires the aws-cli https://aws.amazon.com/cli/

aws s3 sync s3://spiritedmedia-com/wp-content/uploads/ /var/www/spiritedmedia.com/htdocs/wp-content/uploads/
