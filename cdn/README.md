# Content Delivery Networks

Most of the requests to from a page are to static assets like CSS, JavaScript, and images. These need to be delievered as quickly as possible so we use content delivery networks (CDNs) to do this.

The network topology looks like this:

**a.spirited.media** This is our public facing URL for CDN content. It's pretty. It needs to be a CNAME record in order to map to our BunnyCDN hostname

**spiritedmedia.b-cdn.net.com** This is the hostname BunnyCDN gave us. If the request was previously cached, BunnyCDN returns the request. Otherwise it passes the request on to an origin to get a copy of the file.

For files ending in `css` or `js` we use Edge Rules to override the origin to go to `https://spiritedmedia.com`. This way we don't need to sync CSS and JavaScript assets to S3 to be served by our CDN.

Otherwise requests get handed off to CloudFront where they will be fetched from our S3 bucket.

**d9nsjsuh3e2lm.cloudfront.net** Our CloudFront URL that has a Lambda@Edge function associated with it to handle dynamically resizing images on the fly. See [Tachyon Edge](https://github.com/spiritedmedia/tachyon-edge/). If the request is an image it will be processed, otherwise we pass the request on to our S3 bucket.

**spiritedmedia-com.s3.amazonaws.com** The hostname of our S3 bucket which is our source of truth for uploaded media. All production servers sync their uploaded media to this bucket where it can live on after the servers go away as needed.

This is also the backup source for our media when the CDN is down for whatever reason. See https://github.com/spiritedmedia/spiritedmedia/pull/2968

## BunnyCDN

[BunnyCDN](https://bunnycdn.com) handles the bulk of our traffic because it is much cheaper than Amazon's CDN [CloudFront](https://aws.amazon.com/cloudfront/): $0.01/GB vs $0.085/GB. We do about 2-3 TB of bandwidth a month ($20 - 30).

### BunnyCDN Configuration
 - Override Cache-Control headers. We set the expiration of assets on BunnyCDN to be 1 year from the time they were accessed.
 - Disable Cookies = `true`. Strips the cookie headers on the request to improve our caching efficency.
 - Ignore Query Strings = `false`. Query strings are important to us so we will cache a new asset if the query string is different.
 - Ignore Vary Header = `true`. This will improve our cache hit rate.
 - Forward Host Header = `true`. This will pass along the host name, `a.spirited.media`.
 - `*.css` and `*.js` requests will have their origins changed to `https://spiritedmedia.com` where those static assets will be served.
