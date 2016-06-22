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
