# Initial Image
Create a new instance based off of an Ubuntu AMI `Ubuntu Server 14.04 LTS (HVM), SSD Volume Type (64-bit)`

Use an HVM AMI not a PV AMI. Apparently HVM is better. See [http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/virtualization_types.html](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/virtualization_types.html)

 - Instance type: `t2.small` for production
 - VPC: Prod - Spirited Media
 - IAM role: CodeDeploy-EC2
 - Key pair name: EC2 - Prod - Spirited Media

## User Data
```
#!/bin/bash
source /var/www/staging.spiritedmedia.com/scripts/deploy-staging.sh
```

## Tags
- Name: Staging - Spirited Media
- Environment: Staging

## Security Groups
- Web Server - Prod - Spirited Media (Enables HTTP traffic on Port 80)

# Accessing the Initial Image
Find the Public DNS and Public IP information for the instance from the AWS console.

Use the Public DNS hostname to SSH into with the user as `ubuntu`. It would be a good idea to add this to your `~/.ssh/config` file to make life easier.

```
Host spiritedmedia.com
	HostName spiritedmedia.com
	Port 22
	User ubuntu
	IdentityFile ~/.ssh/spirited-media/EC2-Prod-SpiritedMedia.pem
```
Now simply type `ssh spiritedmedia.com` in your terminal to connect to the machine.

# Initial Set-up
After SSHing into the instance for the first time we need to set things up.

```
# Update all of the packages
sudo apt-get update

# Install AWS CodeDeploy Agent
# See http://docs.aws.amazon.com/codedeploy/latest/userguide/how-to-run-agent.html#how-to-run-agent-install-ubuntu
sudo apt-get install python-pip
sudo apt-get install ruby2.0

# Note: You may need to change the subdomain if you're in a different AWS region
# See http://docs.aws.amazon.com/codedeploy/latest/userguide/how-to-run-agent.html#how-to-run-agent-install-ubuntu
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

# Install EasyEngine
wget -qO ee rt.cx/ee && sudo bash ee

# Enable auto-completeition for ee commands
source /etc/bash_completion.d/ee_auto.rc

# Create a site for spiritedmedia.com
sudo ee site create spiritedmedia.com --wpsubdomain --wpredis --php7 --user=admin --pass=admin --email=systems@spiritedmedia.com --experimental

# Install Admin/dev tools
sudo ee stack install --admin

# Install phpRedisAdmin for exploring the contents of the Redis cache
sudo ee stack install --phpredisadmin

# Change permissions for accessing the dev tools on port 22222
# Set to 'spiritedmedia' and 'spirited' for convenience
sudo ee secure --auth


# Clone our application repo containing wp-content stuff
cd /var/www/spiritedmedia.com/htdocs/
sudo git init
sudo git remote add origin git@github.com:spiritedmedia/pedestal-build.git

# Create a new SSH key so our server and talk to our private GitHub repo
sudo ssh-keygen -t rsa -b 4096 -C "systems+ec2@spiritedmedia.com"

# Manually copy the public key and add it as a new deploy key on GitHub
# See https://developer.github.com/guides/managing-deploy-keys/#deploy-keys
sudo cat /root/.ssh/id_rsa.pub

# Force update from the repo
# See http://stackoverflow.com/a/8888015
sudo git fetch --all
sudo git reset --hard origin/master

# Reset ownership of files from root to www-data
sudo chown -R www-data:www-data htdocs/
```

Now login to WordPress and set things up the way they need to be set-up (delete unecessary themes and plugins etc).

## wp-config.php

Recommended additions to the wp-config.php file:

Check to make sure `WP_ALLOW_MULTISITE` isn't defined twice!

```
// For the Domain Mapping plugin, Mercator
define( 'SUNRISE', 'on' );
```

```
// Add redis cache credentails for WP Redis plugin
// redis.spiritedmedia.com is set to mirror the Redis Endpoint in the ElasticCache console
$redis_server = array(
    'host' => 'redis.spiritedmedia.com',
    'port' => 6379,
);
```

```
// Add the RDS database credentials. Don't use the local database set-up by EasyEngine.

// ** MySQL settings ** //

/** The name of the database for WordPress */
define('DB_NAME', 'spiritedmediacom');

/** MySQL database username */
define('DB_USER', 'spiritedmediacom');

/** MySQL database password */
define('DB_PASSWORD', '********');

/** MySQL hostname */
define('DB_HOST', '******.rds.amazonaws.com');
```

```
// S3 User access keys for WP Offload S3 Lite
// See https://deliciousbrains.com/wp-offload-s3/doc/quick-start-guide/
define( 'DBI_AWS_ACCESS_KEY_ID', '********************' );
define( 'DBI_AWS_SECRET_ACCESS_KEY', '****************************************' );

```

## Set-up the Deploy Script
Copy `deploy-production.sh` to `/var/www/spiritedmedia.com/scripts/deploy-production.sh`. This is used by AWS CodeDeploy to update the application from our build repo so the server is running the latest version of the code.

# Create an AMI
Save an AMI via the AWS Console once everything is in it's right place. The AMI will be used to launch new instances for autoscaling. This also provides a backup to the server before major upgrades.

# Full Page Caching with Redis and ElastiCache

EasyEngine makes it easy to handle full page caching via Redis. See [EasyEngine 3.3 released with Full-Page Redis Cache support](https://easyengine.io/blog/easyengine-3-3-full-page-redis-cache/)

- Cache TTL is 4 hours
- Caching behavior is controlled set through the [Nginx Helper plugin](https://wordpress.org/plugins/nginx-helper/) in the Network Settings: <http://spiritedmedia.com/wp-admin/network/settings.php?page=nginx>
- Be sure to update the hostname value to `redis.spiritedmedia.com`
- Only requests to PHP pages are cached in Redis
- Requests with query strings in the URL are not cached
- You can see what's cached using the [phpRedisAdmin tool](https://spiritedmedia.com:22222/cache/redis/phpRedisAdmin) (look for the `nginx-cache` key)
- Check the `X-SRCache-Fetch-Status` header of the response in Dev tools to determine if the page was cached or not (HIT or MISS or BYPASS)

<img width="678" alt="Look for X-SRCache-Fetch-Status" src="https://cloud.githubusercontent.com/assets/867430/17533469/d8069d7c-5e52-11e6-965e-3b1a68c54788.png">

# Glossary
**AMI** - Amazon Machine Image, Amazon's own virtual machine format

**HVM** - Hardware Virtual Machine provides the ability to run an operating system directly on top of a virtual machine without any modification, as if it were run on the bare-metal hardware.

**PV** - Paravirtual guests can run on host hardware that does not have explicit support for virtualization, but they cannot take advantage of special hardware extensions such as enhanced networking or GPU processing.
