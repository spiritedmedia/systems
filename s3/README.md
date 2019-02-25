# aka Amazon Unlimited FTP Server

We use S3 to store media uploads with the help of the [S3 Uploads](https://github.com/humanmade/S3-Uploads) plugin. This frees us from trying to sync media between multiple servers. We mask the S3 URL with our own domain so we can serve uploads via BunnyCDN which is $0.01/GB vs. $0.085/GB for CloudFront. [See the CDN section](../cdn/)

https://a.spirited.media --> https://spiritedmedia.b-cdn.net.com (BunnyCDN) --> https://d9nsjsuh3e2lm.cloudfront.net (CloudFront w/ Lambda@Edge function) --> https://spiritedmedia-com.s3.amazonaws.com

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

Using the [AWS CLI](https://aws.amazon.com/cli/) tool we can sync with S3.

To sync an S3 bucket to a server do this:
```
aws s3 sync s3://spiritedmedia-com/wp-content/uploads/ /var/www/spiritedmedia.com/htdocs/wp-content/uploads/
```

To push files from a server to an S3 bucket and make them public on S3 do this:

```
aws s3 sync /var/www/spiritedmedia.com/htdocs/wp-content/uploads/ s3://spiritedmedia-com/wp-content/uploads/ --acl public-read
```

See the [spiritedmedia.com web servers](../web-servers/spiritedmedia.com) section for more details.

## aws.spiritedmedia.com Redirect

To make it easier to redirect to our AWS console sign in screen, a redirect has been setup in S3. A bucket, `aws.spiritedmed.com` has been setup. In the properties from that bucket Static Website Hosting has been setup to redirect all requests to our AWS console sign in screen. A record in Route 53 maps `aws.spiritedmedia.com` to the S3 endpoint for the aws.spiritedmedia.com bucket. We have to do it this way because there is no way to redirect to a path in a request from DNS alone.

![screen shot 2019-02-14 at 12 41 14 pm](https://user-images.githubusercontent.com/867430/52806232-72a13900-3056-11e9-8ab7-e04d62b10f04.jpg)
