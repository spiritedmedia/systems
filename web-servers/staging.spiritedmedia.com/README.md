# Initial Image
Create a new instance based off of an Ubuntu AMI `Ubuntu Server 14.04 LTS (HVM), SSD Volume Type (64-bit)`

Use an HVM AMI not a PV AMI. Apparently HVM is better. See [http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/virtualization_types.html](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/virtualization_types.html)

 - Instance type: `t2.micro` for testing, `t2.medium` for production
 - VPC: Stage - Spirited Media
 - IAM role: CodeDeploy-EC2
 - Key pair name: EC2 - Stage - Spirited Media

## User Data
```
#!/bin/bash
source /var/www/staging.spiritedmedia.com/scripts/deploy-staging.sh
```

## Tags
- Name: Staging - Spirited Media
- Environment: Staging

## Security Groups
- Web Server - Stage - Spirited Media (Enables HTTP traffic on Port 80)
- Developer SSH (Enables SSH access for approved IPs)

# Accessing the Initial Image
Find the Public DNS and Public IP information for the instance from the AWS console.

Use the Public DNS hostname to SSH into with the user as `ubuntu`. It would be a good idea to add this to your `~/.ssh/config` file to make life easier.

```
Host staging.spiritedmedia.com
	HostName staging.spiritedmedia.com
	Port 22
	User ubuntu
	IdentityFile ~/.ssh/spirited-media/EC2-Stage-SpiritedMedia.pem
```
Now simply type `ssh staging.spiritedmedia.com` in your terminal to connect to the machine.

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

# Create a site for staging.spiritedmedia.com
sudo ee site create staging.spiritedmedia.com --wpsubdomain --php7 --user=admin --pass=admin --email=systems@spiritedmedia.com --experimental

# Install Admin/dev tools
sudo ee stack install --admin

# Install Redis
sudo ee stack install --redis

# Install phpRedisAdmin for exploring the contents of the Redis cache
sudo ee stack install --phpredisadmin

# Change permissions for accessing the dev tools on port 22222
# Set to 'spirited' and 'media' for convenience
sudo ee secure --auth


# Clone our application repo containing wp-content stuff
cd /var/www/staging.spiritedmedia.com/htdocs/
sudo git init
sudo git remote add origin git@github.com:spiritedmedia/spiritedmedia-build.git

# Create a new SSH key so our server and talk to our private GitHub repo
sudo ssh-keygen -t rsa -b 4096 -C "systems+ec2@spiritedmedia.com"

# Manually copy the public key and add it as a new deploy key on GitHub
# See https://developer.github.com/guides/managing-deploy-keys/#deploy-keys
sudo cat /root/.ssh/id_rsa.pub

# Force update from the repo
# !!! Make sure to check out the staging branch !!!
# See http://stackoverflow.com/a/8888015
sudo git fetch --all
sudo git reset --hard origin/staging

# Reset ownership of files from root to www-data
sudo chown -R www-data:www-data htdocs/
```

Now login to WordPress and set things up the way they need to be set-up (delete unecessary themes and plugins etc).

## wp-config.php

Recommended additions to the wp-config.php file:

```
// For the Domain Mapping plugin, Mercator
define( 'SUNRISE', 'on' );

// Add redis cache credentails for WP Redis plugin
$redis_server = array(
    'host' => '127.0.0.1',
    'port' => 6379,
);

// S3 User access keys for WP Offload S3 Lite
// See https://deliciousbrains.com/wp-offload-s3/doc/quick-start-guide/
define( 'DBI_AWS_ACCESS_KEY_ID', '********************' );
define( 'DBI_AWS_SECRET_ACCESS_KEY', '****************************************' );

```

## Set-up the Deploy Script
Copy `deploy-staging.sh` to `/var/www/scripts/deploy-staging.sh`. This is used by AWS CodeDeploy to update the application from our build repo so the server is running the latest version of the code.

## Password Protection
Because this is a staging server we only want certain people to be able to access it. Adding a basic authentication layer keeps the public out as well as bots. See the `basic-auth.conf` file in the [nginx section](../nginx/).

## Database Backups
We perform daily database backups so we have a way to revert changes if need be. The [AutoMySQLBackup](https://sourceforge.net/projects/automysqlbackup/) script performs the dump and [S3cmd-sync](http://s3tools.org/s3cmd-sync) syncs the files to the `staging-spiritedmedia-com` S3 bucket.

### Install AutoMySQLBackup
```
# Download AutoMySQLBackup from Source Forge
sudo wget http://downloads.sourceforge.net/project/automysqlbackup/AutoMySQLBackup/AutoMySQLBackup%20VER%203.0/automysqlbackup-v3.0_rc6.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fautomysqlbackup%2F&ts=1471914576&use_mirror=superb-sea2

# Move it to the backups directory and rename the downloaded payload
sudo mv automysqlbackup-v3.0_rc6.tar.gz\?r\=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fautomysqlbackup%2F /var/www/staging.spiritedmedia.com/backups/automysqlbackup/automysqlbackup-v3.0_rc6.tar.gz

cd /var/www/staging.spiritedmedia.com/backups/automysqlbackup/

sudo tar -xvzf automysqlbackup-v3.0_rc6.tar.gz
```

We need to get the database credentials that EasyEngine set-up for our site. Run `sudo ee site info staging.spiritedmedia.com` and copy the `DB_NAME`, `DB_USER`, and `DB_PASS` values.

Edit `/var/www/staging.spiritedmedia.com/backups/automysqlbackup/automysqlbackup.conf` and uncomment the following values:

```
# Username to access the MySQL server e.g. dbuser
CONFIG_mysql_dump_username='DB_USER'

# Password to access the MySQL server e.g. password
CONFIG_mysql_dump_password='DB_PASS'

# Host name (or IP address) of MySQL server e.g localhost
CONFIG_mysql_dump_host='localhost'

# Backup directory location e.g /backups
CONFIG_backup_dir='/var/www/staging.spiritedmedia.com/backups/db'

# List of databases for Daily/Weekly Backup e.g. ( 'DB1' 'DB2' 'DB3' ... )
# set to (), i.e. empty, if you want to backup all databases
CONFIG_db_names=()

# List of databases for Monthly Backups.
# set to (), i.e. empty, if you want to backup all databases
CONFIG_db_month_names=()

# List of DBNAMES to EXLUCDE if DBNAMES is empty, i.e. ().
CONFIG_db_exclude=( 'information_schema' )

# While a --single-transaction dump is in process, to ensure a valid dump file (correct table contents and
# binary log coordinates), no other connection should use the following statements: ALTER TABLE, CREATE TABLE,
# DROP TABLE, RENAME TABLE, TRUNCATE TABLE. A consistent read is not isolated from those statements, so use of
# them on a table to be dumped can cause the SELECT that is performed by mysqldump to retrieve the table
# contents to obtain incorrect contents or fail.
CONFIG_mysql_dump_single_transaction='no'

# Choose Compression type. (gzip or bzip2)
CONFIG_mysql_dump_compression='gzip'

# Store an additional copy of the latest backup to a standard
# location so it can be downloaded by third party scripts.
CONFIG_mysql_dump_latest='yes'

# Remove all date and time information from the filenames in the latest folder.
# Runs, if activated, once after the backups are completed. Practically it just finds all files in the latest folder
# and removes the date and time information from the filenames (if present).
CONFIG_mysql_dump_latest_clean_filenames='no'

CONFIG_mysql_dump_differential='no'

# What would you like to be mailed to you?
# - log   : send only log file
# - files : send log file and sql files as attachments (see docs)
# - stdout : will simply output the log to the screen if run manually.
# - quiet : Only send logs if an error occurs to the MAILADDR.
CONFIG_mailcontent='log'

# Email Address to send mail to? (user@domain.com)
CONFIG_mail_address='systems@spiritedmedia.com'
```

### Install S3cmd

See the [S3 section](../../s3#install-s3cmd).


### Create a `backup.sh` Script

Create `/var/www/staging.spiritedmedia.com/backups/backup.sh` and paste the following:

```
#!/bin/bash

# DB backup
/var/www/staging.spiritedmedia.com/backups/automysqlbackup/automysqlbackup -bc /var/www/staging.spiritedmedia.com/backups/automysqlbackup/automysqlbackup.conf

# S3 Sync for offsite backup of DB files
s3cmd sync /var/www/staging.spiritedmedia.com/backups/db/ s3://staging-spiritedmedia-com/db/
```

Give it a test run `sudo ./backup.sh`. Check the S3 bucket to make sure the files successfully synced.

You can automate the backups via a cron job, `sudo crontab -e`.

Add the following, use [crontab.guru](http://crontab.guru/) to identify the timing:

```
# At 3:29 every day run the DB backup script
29 3 * * * /var/www/staging.spiritedmedia.com/backups/backup.sh > /dev/null 2>&1
```

# Create an AMI
Save an AMI via the AWS Console once everything is in it's right place. The AMI will be used to relaunch the instance if necessary. This also provides a backup to the server before major upgrades.


# Glossary
**AMI** - Amazon Machine Image, Amazon's own virtual machine format

**HVM** - Hardware Virtual Machine provides the ability to run an operating system directly on top of a virtual machine without any modification, as if it were run on the bare-metal hardware.

**PV** - Paravirtual guests can run on host hardware that does not have explicit support for virtualization, but they cannot take advantage of special hardware extensions such as enhanced networking or GPU processing.
