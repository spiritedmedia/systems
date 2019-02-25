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

## Updating Ciphers ERR_SPDY_INADEQUATE_TRANSPORT_SECURITY 

If you see an error message in your browser along the lines of "refusing to connect to site" or `ERR_SPDY_INADEQUATE_TRANSPORT_SECURITY` the SSL ciphers used by nginx are probably out of date. This command will fix that and only use secure ciphers.

```
sed -i 's/ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHADHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:ECDHE-ECDSA-DES-CBC3-SHA:AES128-GCM-SA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!ECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA;/ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS;/' /etc/nginx/nginx.conf
```

See <https://community.easyengine.io/t/chrome-security-issue/8499/8> and <https://community.qualys.com/thread/17604-the-dreaded-errspdyinadequatetransportsecurity-error-in-chrome>

## Resources
 - [EasyEngine Let's Encrypt docs](https://easyengine.io/docs/lets-encrypt/)
 - [SSL Labs Test Results](https://www.ssllabs.com/ssltest/analyze.html?d=staging.billypenn.com&hideResults=on&latest)