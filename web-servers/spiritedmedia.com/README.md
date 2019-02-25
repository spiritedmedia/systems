In production we run multiple servers for redundancy and high availability in an auto scaling group. Separate components are on their own hardware (dedicated machines for WordPress, Redis, Aurora Database, S3 bucket for media).

![image](https://user-images.githubusercontent.com/867430/52797501-0584a800-3044-11e9-8832-ffc12820f9e7.png)

# Initial Image
Create a new instance based off of an Ubuntu AMI `Ubuntu Server 18.04 LTS (HVM), SSD Volume Type (64-bit)`

Use an HVM AMI not a PV AMI. Apparently HVM is better. See [http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/virtualization_types.html](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/virtualization_types.html)

 - Instance type: `t2.small` for production
 - VPC: Prod - Spirited Media
 - IAM role: CodeDeploy-EC2
 - Key pair name: EC2 - Prod - Spirited Media

## User Data
```
#!/bin/bash
source /var/www/spiritedmedia.com/scripts/deploy-production.sh
```

## Tags
- Name: Production - Spirited Media
- Environment: Production

## Security Groups
- Web Server - Prod - Spirited Media (Enables HTTP traffic on port 80, HTTPS traffic on port 443)

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
Now type `ssh spiritedmedia.com` in your terminal to connect to the machine.

# Initial Set-up
After SSHing into the instance for the first time we need to set things up.

```
# Update all of the packages
sudo apt-get update

# Install AWS CodeDeploy Agent
# See http://docs.aws.amazon.com/codedeploy/latest/userguide/how-to-run-agent.html#how-to-run-agent-install-ubuntu
sudo apt-get install python-pip
sudo apt-get install ruby

# Note: You may need to change the subdomain if you're in a different AWS region
# See http://docs.aws.amazon.com/codedeploy/latest/userguide/how-to-run-agent.html#how-to-run-agent-install-ubuntu
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

# Install EasyEngine
wget -qO ee rt.cx/ee && sudo bash ee

# Enable auto-completion for ee commands
source /etc/bash_completion.d/ee_auto.rc

# Create a site for spiritedmedia.com
sudo ee site create spiritedmedia.com --wpsubdomain --wpredis --php7 --user=admin --pass=admin --email=systems@spiritedmedia.com --experimental

# Forcing the usage of WordPress 4.9 until we officially support 5.0"
sudo wp core update --version=4.9.8 --force --allow-root

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

Set `define('DB_CHARSET', 'utf8mb4');` for UTF8 Multibyte characters (aka emojis) to work.

```
define( 'WPMU_ACCEL_REDIRECT', true );

// Don't allow WordPress to auto update itself
// We take care of that via baking new AMIs
define( 'WP_AUTO_UPDATE_CORE', false );
define( 'DISALLOW_FILE_MODS', true );

// We use an external cron See https://github.com/spiritedmedia/spiritedmedia/pull/2548
define( 'DISABLE_WP_CRON', true );
define( 'WP_POST_REVISIONS', 30 );

define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );

// URLs with ?debug=!wr8KCsv9V7% in them are shown PHP debugging info + SQL query info
if ( isset( $_GET['debug'] ) && $_GET['debug'] == '!wr8KCsv9V7%' ) {
    define( 'WP_DEBUG_DISPLAY', true );
    define( 'SAVEQUERIES', true );
} else {
    define( 'WP_DEBUG_DISPLAY', false );
}

// redis.spiritedmedia.com is mapped to the ElastiCache cluster endpoint
// This allows us to make changes to these without needing to bake a new AMI
// $redis_server is for our Object Cache plugin
$redis_server = array(
    'host' => 'redis.spiritedmedia.com',
    'port' => 6379,
);

// These are for are Redis full page cache purging plugin
define( 'REDIS_CACHE_PURGE_HOST', 'redis.spiritedmedia.com' );
define( 'REDIS_CACHE_PURGE_PORT', '6379' );

// AWS API Keys for S3 Uploads plugin
define( 'S3_UPLOADS_BUCKET', 'spiritedmedia-com' );
define( 'S3_UPLOADS_KEY', '********************' );
define( 'S3_UPLOADS_SECRET', '********************' );
define( 'S3_UPLOADS_REGION', 'us-east-1' );
define( 'S3_UPLOADS_BUCKET_URL', 'https://a.spirited.media' );

define( 'TACHYON_URL', S3_UPLOADS_BUCKET_URL . '/wp-content/uploads' );

// AWS API Keys for AWS SES wp_mail() drop-in
define( 'AWS_SES_WP_MAIL_REGION', 'us-east-1' );
define( 'AWS_SES_WP_MAIL_KEY', '********************' );
define( 'AWS_SES_WP_MAIL_SECRET', '********************' );

// MailChimp API Credentials for Prod
define( 'MAILCHIMP_API_KEY', '********************' );

// YouTube Data API Key
define( 'YOUTUBE_DATA_API_KEY', '********************' );

# For the Mercator Domain Mapping plugin
define( 'SUNRISE', 'on' );

define( 'WP_ALLOW_MULTISITE', true );
define( 'MULTISITE', true );
define( 'SUBDOMAIN_INSTALL', true );
$base = '/';
define( 'DOMAIN_CURRENT_SITE', 'spiritedmedia.com' );
define( 'PATH_CURRENT_SITE', '/' );
define( 'SITE_ID_CURRENT_SITE', 1 );
define( 'BLOG_ID_CURRENT_SITE', 1 );

if ( ! empty( $_SERVER['HTTP_X_FORWARDED_FOR'] ) ) {
  /*
  Set $_SERVER variables if the request is being passed from an HTTPS request from the load balancer. Otherwise is_ssl() doesn't work and we get endless redirects
  */
  if ( 'https' === $_SERVER['HTTP_X_FORWARDED_PROTO'] ) {
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = '443';
  }
  /*
  Set $_SERVER['REMOTE_ADDR'] to the real IP address of the requester
  See https://core.trac.wordpress.org/ticket/9235#comment:40
  */
  $parts = explode( ',', $_SERVER['HTTP_X_FORWARDED_FOR'] );
  $_SERVER['REMOTE_ADDR'] = $parts[0];
  unset( $parts );
}
```

## Install `aws-cli` Tools

```
pip3 install awscli --upgrade --user
```


## AWS CloudWatch Log Monitoring
We can send server logs to CloudWatch where they can be analyzed in one central location. First you need to [install the AWS CloudWatch agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-on-first-instance.html).

```
wget https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py
sudo python awslogs-agent-setup.py -r us-east-1
```

Then we can update the configuration to point to the log files we want to monitor. Edit `/var/awslogs/etc/awslogs.conf`

```
[/var/nginx/spiritedmedia.com.error.log]
datetime_format = %Y/%m/%d %H:%M:%S
file = /var/log/nginx/spiritedmedia.com.error.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = /var/log/nginx/spiritedmedia.com.error.log

[/var/log/nginx/error.log]
datetime_format = %Y/%m/%d %H:%M:%S
file = /var/log/nginx/error.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = /var/log/nginx/error.log

[/var/nginx/spiritedmedia.com.access.log]
datetime_format = %d/%b/%Y %H:%M:%S %z
file = /var/log/nginx/spiritedmedia.com.access.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = /var/log/nginx/spiritedmedia.com.access.log

[/var/www/spiritedmedia.com/htdocs/wp-content/debug.log]
datetime_format = %d-%b-%Y %H:%M:%S
time_zone = UTC
file = /var/www/spiritedmedia.com/htdocs/wp-content/debug.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = /var/www/spiritedmedia.com/htdocs/wp-content/debug.log
```
Then restart the `awslogs` service: `sudo service awslogs restart`

It might be a good idea to setup a cron job that restarts the awslogs service every day or so as it tends to stop sending logs after some time.

See https://github.com/spiritedmedia/systems/issues/23 and https://github.com/spiritedmedia/systems/issues/31

## Set-up the Deploy Script
Copy `deploy-production.sh` to `/var/www/spiritedmedia.com/scripts/deploy-production.sh`. This is used by AWS CodeDeploy to update the application from our build repo so the server is running the latest version of the code.

## Update OS Packages
Every time you bake a new AMI it is a good idea to update the operating system packages and purge old kernals that take up space. This can be done by running `~/.update-os.sh`.

# Create an AMI
Save an AMI via the AWS Console once everything is in it's right place. The AMI will be used to launch new instances for autoscaling. This also provides a backup to the server before major upgrades.

See [updating-ami-for-spiritedmedia-com.md](updating-ami-for-spiritedmedia-com.md) for steps on baking and deploying a new AMI.

# Load Balancing and Auto Scaling

Since the production environment uses multiple servers we need a load balancer to evenly distribute the traffic. You'll need to setup an SSL certificate using Amazon's ACM service before continuing. See the [SSL README.md](ssl/). 

 - Create a new [Application Load Balancer](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#V2CreateELBWizard:type=application:)
 - The scheme should be `internet-facing`
 - Add a listener for HTTP (port 80) and HTTPS (port 443) traffic
 - Select a VPC and which subnets you want to provide traffic to (usually you would select all available subnets)
 - Choose the certificate created in ACM (you'll want spiritedmedia.com which has aliases for each of the three sites)
 - Use the `ELB - Prod - Spirited Media` security group (allow inbound traffic on port 80 and port 443 from anywhere)
 - Specify the health check path to `/health-check.php` (The response from this file is how the load balancer determines if the instances are healthy and able to recieve traffic)
 - Health check thresholds (an instance is considered healthy if it has responded successfully to 3 health checks in a row with a 200 status code)
 	-  Healthy Threshold: 3
 	-  Unhealthy threshold: 6
 	-  Timeout: 15
 	-  Interval: 30
 	-  Success codes: 200 

The target group attributes will need to be modified to the following:
 - Deregistration delay: 300 seconds
 - Slow start duration: 0 seconds
 - Stickiness: Enabled for 1 day

If an instance is shutting down we will wait 300 seconds so clients can be routed to the other available instance (aka connection draining). Stickiness needs to be enabled so logged-in users are sent to the same instance where they might upload media which we want them to see right away before it gets uploaded to S3.

Auto scaling groups are controlled by a launch configuration. The launch configuration defines the properties of the instances that will be launched and which AMI to use. After [baking a new AMI](updating-ami-for-spiritedmedia-com.md) the launch configuration needs to be updated by creating a copy and making changes. Then the autoscaling group can be told to use the new launch configuration and start replacing instances manually in the AWS console. 

The load balancer is attached to the auto scaling group so any instances added to the auto scaling group are automatically registered with the load balancer and can start receiving traffic. 

The desired auto scaling capacity should be 2 instances (1 in each availability zone). The minimum capacity is 2 and the maximum capacity is 4 (to control costs). A cooldown period of 120 seconds ensures we don't launch new instances too fast if there is a problem when launching the new instances (otherwise we could get an endless loop of the auto scaling group creating and destroying instances). The health check type should be ELB (aka the load balancer is what determines if the instances are healthy or not).

Make sure new instances are tagged with the key `Environment` and the value `Production` so they can get code updates from AWS CodeDeploy. 

Use the Activity History tab to monitor when new instances are being created to make sure everything is working right and you're not in a loop of spawning bad instances and killing them right away.


# Full Page Caching with Redis and ElastiCache

EasyEngine makes it easy to handle full page caching via Redis. See [EasyEngine 3.3 released with Full-Page Redis Cache support](https://easyengine.io/blog/easyengine-3-3-full-page-redis-cache/)

- Cache TTL is 4 hours
- Caching behavior is controlled through the [Redis Full Page Cache Purger plugin](https://github.com/spiritedmedia/redis-full-page-cache-purger)
- To use an external Redis server like ElastiCache edit `/etc/nginx/conf.d/upstream.conf` and edit the `upstream redis { server 127.0.0.1:6379; keepalive 10; }` value.
- Be sure to add `define( 'REDIS_CACHE_PURGE_HOST', 'redis.spiritedmedia.com' );` to `wp-config.php`
- Only requests to PHP pages are cached in Redis
- Requests with query strings in the URL are cached but some query parameters are ignored. See https://github.com/spiritedmedia/spiritedmedia/pull/3086
- Check the `X-SRCache-Fetch-Status` header of the response in Dev tools to determine if the page was cached or not (HIT or MISS or BYPASS)
- You can flush the entire Redis cache by SSHing into the server and running `./flush-redis.sh`

<img width="678" alt="Look for X-SRCache-Fetch-Status" src="https://cloud.githubusercontent.com/assets/867430/17533469/d8069d7c-5e52-11e6-965e-3b1a68c54788.png">
