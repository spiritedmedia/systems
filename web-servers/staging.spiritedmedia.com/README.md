# Initial Image
Create a new instance based off of an Ubuntu AMI `Ubuntu Server 14.04 LTS (HVM), SSD Volume Type (64-bit)`

Use an HVM AMI not a PV AMI. Apparently HVM is better. See [http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/virtualization_types.html](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/virtualization_types.html)

 - Instance type: `t2.micro` for testing, `t2.medium` for production
 - VPC: Stage - Spirited Media
 - IAM role: CodeDeploy-EC2
 - Key paid name: EC2 - Stage - Spirited Media
 
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
sudo ee site create staging.spiritedmedia.com --wpsubdomain --php7 --user=admin --pass=admin --email=product@billypenn.com --experimental

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
sudo git remote add origin git@github.com:spiritedmedia/pedestal-beta.git

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

## Password Protection
Because this is a staging server we only want certain people to be able to access it. Adding a basic authentication layer keeps the public out as well as bots. 

```
# Install apache2-utils for generating the password
sudo apt-get install apache2-utils

# Create a new password file for the user 'spirited'
sudo htpasswd -c /var/www/staging.spiritedmedia.com/conf/nginx/.htpasswd spirited

# When prompted enter a password. Let's use 'media'

# Copy basic-auth.conf from this repo to /var/www/staging.spiritedmedia.com/conf/nginx/basic-auth.conf
```

# Create an AMI
Save an AMI via the AWS Console once everything is in it's right place. The AMI will be used to relaunch the instance if necessary. This also provides a backup to the server before major upgrades.


# Glossary
**AMI** - Amazon Machine Image, Amazon's own virtual machine format

**HVM** - Hardware Virtual Machine provides the ability to run an operating system directly on top of a virtual machine without any modification, as if it were run on the bare-metal hardware. 

**PV** - Paravirtual guests can run on host hardware that does not have explicit support for virtualization, but they cannot take advantage of special hardware extensions such as enhanced networking or GPU processing.

  	
