# SSL for spiritedmedia.com

We use Amazon Web Services' [Certificate Manager](https://aws.amazon.com/certificate-manager/) service for our fleet of production servers. The service automatically handles deploying certs and keys, renewal, and it's free. Once it is up and running there isn't much to do.

## Adding a New Domain

When modifying a certificate a new cert needs to be requested, generated, and associated with our load balancer. This can be done at https://console.aws.amazon.com/acm/home?region=us-east-1#/ There is no way to edit a cert once it has been issued.

## Domain Verification

To verify we own and control the domains we want a certfificate for Amazon sends email to the addresses listed in the whois records of the domain name. systems@spiritedmedia.com has been added as the contact for the Admin section of the Who Is records for all of our domains. 

## Terminating at the Load Balancer

The Certificate Manager service requires a load balancer which handles SSL termination taking the load off of the individual EC2 instances and simplifying management.

## Application Load Balancer

When adding SSL certs we decided to "upgrade" from the Classic Elastic Load Balancer to the Application Elastic Load Balancer mainly for HTTP/2 support and the potential for more flexibility down the road.

The biggest configuration difference is Application Load Balancers have *listeners* that the load balancer listens to from outside traffic and *targets* that the load balancer passes to the request to on the backend. The ports don't have to be the same (i.e. listen on port 80 and send it to the server on port 8080)

Our EC2 instances are listening to requests from the load balancer on port 80 (including secure connections).

We need to enable stickiness on the load balancer so repeat requests get routed to the same server. This is important for logged in users otherwise they would constantly get logged out as they bounced between servers.

## nginx Tweaks

Since SSL requests are preffered, we can rediret all non-secure requests to their `https` equivalent with this logic added to `/etc/nginx/sites-available/spiritedmedia.com`:

```
set $redirect_to_https 0;
if ( $http_x_forwarded_proto != 'https' ) {
  set $redirect_to_https 1;
}
if ( $request_uri = '/health-check.php' ) {
  set $redirect_to_https 0;
}
if ( $redirect_to_https = 1 ) {
  return 301 https://$host$request_uri;
}
```
The load balancer appends the header `X-FORWARDED_PROTO` to all requests so we can determine if the request was originally secure or not. Those that aren't ecure will be redirected to the secure, https, version.

## wp-config.php Tweaks

WordPress' core function [`is_ssl()`](https://developer.wordpress.org/reference/functions/is_ssl/) depends on certain `$_SERVER` superglobal variables set. We need to handle this ourselves and check for the `X-FORWARDED-PROTO` request header.

```
/*
Set $_SERVER variables if the request is being passed from an HTTPS request from the load balancer. Otherwise is_ssl() doesn't work and we get endless redirects
*/
if ( 'https' === $_SERVER['HTTP_X_FORWARDED_PROTO'] ) {
  $_SERVER['HTTPS'] = 'on';
  $_SERVER['SERVER_PORT'] = '443';
}
```
If we don't do this then an endless redirect happens in `wp-login.php` due to `is_ssl()` returning `false`.

## Resources
- [SSL Labs Test Results](https://www.ssllabs.com/ssltest/analyze.html?d=billypenn.com)

