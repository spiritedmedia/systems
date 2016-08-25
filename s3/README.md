# aka Amazon Unlimited FTP Server

We use S3 to store media uploads with the help of the [WP Offload S3](https://wordpress.org/plugins/amazon-s3-and-cloudfront/) plugin. This frees us from trying to sync media between multiple servers. We mask the S3 URL with our own domain so we can serve uploads via KeyCDN which is half the price of CloudFront.

https://spirited.media --> KeyCDN --> https://spiritedmedia-com.s3.amazonaws.com

With KeyCDN, we can take advantage of HTTP/2 for faster downloads.

## Naming Buckets
Bucket names should be [DNS compliant](http://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html) meaning lower-case letters, numbers, hyphens, and periods are the only characters that should be used.

There are multiple ways to access a bucket via a URL.

```
Preferred:
<NAME>.s3.amazonaws.com/path/to/file.jpg

s3.amazonaws.com/<NAME>/path/to/file.jpg
```
The preferred way allows us to mask the S3 URL with our own domain via a CNAME record.

## SSL and Buckets
Periods should be avoided as this conflicts with Amazon S3's wildcard SSL certificate.

```
BAD: spiritedmedia.com - https://spiritedmedia.com.s3.amazonaws.com uses a self-signed HTTPS certificate

GOOD: spiritedmedia-com - https://spiritedmedia-com.s3.amazonaws.com works as expected
```

`https://spiritedmedia.com.s3.amazonaws.com` results in a self-signed HTTPS certificate where as  `https://spiritedmedia-com.s3.amazonaws.com` 

## Syncing Media

The [s3cmd](http://s3tools.org/s3cmd) tool is installed on production instances. This allows syncing between a local file system and an S3 bucket.

### Install S3cmd

The easiest way to install S3cmd is via [pip](https://en.wikipedia.org/wiki/Pip_(package_manager)).

```
sudo pip install s3cmd
```

To configure S3cmd run `sudo s3cmd --configure` and follow the prompts. The S3 `Access Key` and `Secret Key` can be accessed via the [IAM dashboard](https://console.aws.amazon.com/iam/home?region=us-east-1). Make sure the user has the policy `AmazonS3FullAccess` attached.

### Sync the Entire `/uploads/` directory

*Note: The `--dry-run` argument needs to be removed before you actually run the sync commands.*

`s3cmd sync --dry-run /var/www/spiritedmedia.com/htdocs/wp-content/uploads/ s3://spiritedmedia-com/wp-content/uploads/`

### Selective Sync
Sync files in the web server root. Exclude everything, include any patterns in a file called sync.include:

`s3cmd sync --dry-run --exclude '*' --include-from sync.include /var/www/spiritedmedia.com/htdocs/ s3://spiritedmedia-com/`

sync.include file:

```
# Comments
*.js
*.css
*.png
*.jpg
*.jpeg
*.bmp
*.gif
*.svg
```

[WP Offload S3 Lite](https://wordpress.org/plugins/amazon-s3-and-cloudfront/) enables media files uploaded to the media library to be copied over to S3 and synced. 