# Overview
 - Reload nginx: `sudo ee stack reload --nginx` 
 - Server-wide configuration: Look in `/etc/nginx/`
 - Site-specific configuration: `/var/www/<site-url>/conf/nginx/`
 - Error log: `/var/log/nginx/error.log`
 - Access log: `/var/log/nginx/access.log`
 - Site Specific error logs: `/var/log/nginx/<site url>.error.log`
 - Site Specific access logs: `/var/log/nginx/<site url>.access.log` 
  
Site specific configuration is also stored in the `sites-available/` directory. The `sites-enabled/` directoy contains sym-links to the configurations in `sites-available/` to enable or disable a site. Delete a sym-link in the `sites-enabled/` directory to disable a site without wiping out the configuration file.

# Nginx Configs

A lot of this was gleaned from the [HTML5 Boiler Plate Server Configs](https://github.com/h5bp/server-configs-nginx) project. EasyEngine also [has a few recommendations](https://easyengine.io/tutorials/nginx/optimization/) 

## Global Configuration

**mime.types** - Replaces /etc/nginx/mime.types provided by EasyEngine. The H5bp version has a few more definitions.

## Site Specific

The following files are site specific and should be added to `/var/www/<site-url>/conf/nginx/`

**basic-auth.conf** - Protect a site behind a basic authentication dialog box. Requires a `.htpasswd` file to define credentails. Recommended for staging servers.

**cache-file-descriptors.conf** - This tells Nginx to cache open file handles, "not found" errors, metadata about files and their permissions, etc. Recommended for production servers.

**expires.conf** - Configure Expires headers for various file types.

**extra-security.conf** - XSS Protection, MIME type sniffing protection etc.

**protect-system-files.conf** - Prevent clients from accessing hidden files (starting with a dot) and backup/config/source files.

**x-ua-compatible.conf** - Force the latest IE version

# Redis Caching with ElastiCache

Edit `/etc/nginx/conf.d/upstream.conf`, look for `upstream redis { server 127.0.0.1:6379; keepalive 10; }` and replace with your ElastiCache endpoint URL, `redis.spiritedmedia.com`.

See <https://github.com/EasyEngine/easyengine/issues/597>

# Misc.

## Reload vs. Restart?
Try reloading first, then resort to restarting. See [When to restart and not reload Nginx?](http://stackoverflow.com/questions/13525465/when-to-restart-and-not-reload-nginx)

