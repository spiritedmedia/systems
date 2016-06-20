# Initial Image
Create a new instance based off of an Ubuntu AMI `Ubuntu Server 14.04 LTS (HVM), SSD Volume Type (64-bit)`

Use an HVM AMI not a PV AMI. Apparently HVM is better. See [http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/virtualization_types.html](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/virtualization_types.html)

 - Instance type: `t2.micro` for testing, `t2.medium` for production
 - VPC: Default (Spiritedmedia-test)
 - IAM role: TODO
 
## Tag Instance
It's a good idea to tag things when we can
 
- Type: Test
 
## Security Group
 To connect to the server we need to enable SSH access but restrict it to our IP. We also need to enable HTTP access to our server.
 
# Accessing the Initial Image
Find the Public DNS and Public IP information for the instance from the AWS console. 

Use the Public DNS hostname to SSH into with the user as `ubuntu`. It would be a good idea to add this to your `~/.ssh/config` file to make life easier.

```
Host spiritedmedia.aws
	HostName ec2-52-207-243-167.compute-1.amazonaws.com
	Port 22
	User ubuntu
	IdentityFile ~/.ssh/spiritedmedia-test.pem
```
Now simply type `ssh spiritedmedia.aws` in your terminal to connect to the machine.

Modify your `hosts` file to map `spiritedmedia.aws` to the public IP of the EC2 instance.

```
# AWS
54.173.19.138 spiritedmedia.aws
```

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

# Create a site for spiritedmedia.aws
sudo ee site create staging.spiritedmedia.com --wpsubdomain --php7 --user=admin --pass=admin --email=product@billypenn.com --experimental

# TODO: Remove MySQL packages from production instances since we'll be using an external database
# sudo ee stack remove --mysql

# Clone our application repo containing wp-content stuff
cd /var/www/spiritedmedia.aws/htdocs/
sudo git init
sudo git remote add origin git@github.com:spiritedmedia/ci-test-build.git

# Create a new SSH key so our server and talk to our private GitHub repo
sudo ssh-keygen -t rsa -b 4096 -C "systems+ec2@spiritedmedia.com"

# Manually copy the public key and add it as a new deploy key on GitHub
sudo cat /root/.ssh/id_rsa.pub

# Force update from the repo
# See http://stackoverflow.com/a/8888015
sudo git fetch --all
sudo git reset --hard origin/master

# Reset ownership of files from root to www-data
sudo chown -R www-data:www-data htdocs/
```
Now login to WordPress and set things up the way they need to be set-up (delete unecessary themes and plugins etc).

Save an AMI once everything is in it's right place. The AMI will be used to launch autoscaled instances. 

# Cloud-init to update instnaces on boot-up
 - [https://www.digitalocean.com/community/tutorials/how-to-use-cloud-config-for-your-initial-server-setup](https://www.digitalocean.com/community/tutorials/how-to-use-cloud-config-for-your-initial-server-setup)
 - [http://fbrnc.net/blog/2015/11/how-to-provision-an-ec2-instance](http://fbrnc.net/blog/2015/11/how-to-provision-an-ec2-instance)

# Bastion Host / Jumpbox
 - Install [Webhook](https://github.com/adnanh/webhook) to trigger deployments / Slack communication
 - Install OpenVPN server (maybe overkill) 
 	- [https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-14-04](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-14-04)
 	- [https://blog.kloud.com.au/2014/04/10/quickly-connect-to-your-aws-vpc-via-vpn/](https://blog.kloud.com.au/2014/04/10/quickly-connect-to-your-aws-vpc-via-vpn/)
 - Set-up AWS CLI
 - Set-up [AWS Missing Tools](https://github.com/colinbjohnson/aws-missing-tools) in order to run [`aws-ha-release.sh`](https://github.com/colinbjohnson/aws-missing-tools/blob/master/aws-ha-release/aws-ha-release.sh) to kill instances on deployment  

# TODO/???
 - Remove MySQL packages from localhost on production. We'll be using an external database
 - Key management and access to private repos? 
 - Security policies
 	- [https://www.reddit.com/r/aws/comments/4mz5ds/what_are_best_practices_in_terms_of_security/](https://www.reddit.com/r/aws/comments/4mz5ds/what_are_best_practices_in_terms_of_security/) 
 - Private subnets for production
 - Do extra VPC's cost money? Could we run the dev server(s) in the default VPC?
 - In CircleCI push current build to a separate branch for rollbacks if need be
 - Make a better README.md file for the build repo to convey the build number and link to CircleCI
 - EE mapping domains issue: [http://community.rtcamp.com/t/wordpress-multisite-domain-mapping/6493](http://community.rtcamp.com/t/wordpress-multisite-domain-mapping/6493)


# Glossary
**AMI** - Amazon Machine Image, Amazon's own virtual machine format

**HVM** - Hardware Virtual Machine provides the ability to run an operating system directly on top of a virtual machine without any modification, as if it were run on the bare-metal hardware. 

**PV** - Paravirtual guests can run on host hardware that does not have explicit support for virtualization, but they cannot take advantage of special hardware extensions such as enhanced networking or GPU processing.

  	
