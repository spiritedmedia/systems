#!/bin/bash
# This script will sync uploaded media on the server to our S3 bucket.
# Use this if you need to push uploads from here to the cloud.
# Requires the aws-cli https://aws.amazon.com/cli/

aws s3 sync /var/www/spiritedmedia.com/htdocs/wp-content/uploads/ s3://spiritedmedia-com/wp-content/uploads/ --acl public-read
