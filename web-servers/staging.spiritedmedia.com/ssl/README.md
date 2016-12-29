# SSL for staging.spiritedmedia.com

We use [Let’s Encrypt](https://letsencrypt.org/) for SSL certs on the single staging server. Amazon Web Services offers an alternative free service but their certificates can only be deployed to Load Balancers and not individual EC2 instances. 

## Renewing the Certificates

Let's Encrypt certificates are valid for 90 days after which they need to be renewed. The renewal process is as simple as running a shell script in `~/renew-ssl-certs.sh`

Let's Encrypt may email reminders to renew the cert at our systems@spiritedmedia.com email address.

*Note: When adding a new domain, an additional `-d` parameter with the domain name needs to be added*

## SSL.conf

The Let's Encrypt bot generates two files:
 
 1. The certificate: `/etc/letsencrypt/live/staging.spiritedmedia.com/fullchain.pem`
 2. The private key:`/etc/letsencrypt/live/staging.spiritedmedia.com/privkey.pem`

 If adding a new domain and re-issuing the cert these files may change and need to up updated in the ssl.conf file located at `/var/www/staging.spiritedmedia.com/conf/nginx/ssl.conf`
 
In `ssl.conf` we also add a redirect to automatic redirect non-HTTPS traffic to HTTPS. We can also take advantage of HTTP/2 on staging now for faster load times. Yay!

## Let's Encrypt and Basic Authentication

Let's Encrypt verifies domain ownership by adding a file to the root and checking the file exists from it's servers. The basic authentication we use to keep the general population off of our staging servers interferes with this.

`/var/www/staging.spiritedmedia.com/conf/nginx/basic-auth.conf` needs to be modified to allow the Let's Encrypt challenge to be requested without a basic auth dialog:

```
# Exclude Let's Encrypt challenge from Basic Auth
location ^~ /.well-known/ {
   auth_basic off;
   allow all;
}
```

## Resources
 - [EasyEngine Let's Encrypt docs](https://easyengine.io/docs/lets-encrypt/)
 - [SSL Labs Test Results](https://www.ssllabs.com/ssltest/analyze.html?d=staging.billypenn.com&hideResults=on&latest)