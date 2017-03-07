# Updating AMI for SpiritedMedia.com

From time to time we need to make changes to the base image we use to start new servers from. This would include updates that aren't part of our repo like WordPress updates, security patches, OS upgrades etc. 

## Before We Begin
- Create a new issue in the [spiritedmedia/systems repo](https://github.com/spiritedmedia/systems/issues). Indicate what changes will be performed so we have a record of it.

## Create a Maintenance Server
This is a server based off of the latest server image that we will make changes to and save a new server image.

- Log on to https://aws.spiritedmedia.com
- Go to the [EC2 Dashboard](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1)
- In the left sidebar find _Images_ --> _AMIs_
- Select the "Latest" AMI for spiritedmedia.com 
- Click the __Launch__ button to create a new EC2 instance based off of this image
- Follow the steps for configuring the new Instance

### Step 2 Instance Type
__t2.micro__ (don't need lots of power, cheaper is better)

### Step 3 Configure Instance Details
```
Number of Instances: 1
	
Network: Prod - Spirited Media
Subnet: Pick any public one (10.0.2.0 - Prod - Public)
Auto-assign Public IP: Use subnet setting (Enable)
	
IAM role: CodeDeploy-EC2
	
Shutdown Behavior: Stop
Enable termination protection: Unchecked
Monitoring: Enable CloudWatch detailed monitoring
Tenancy: Shared- Run a shared hardware instance
	
Network Interfaces: Leave as is
	
Advanced Details: Enter Userdata as text
	
#!/bin/bash
source /var/www/spiritedmedia.com/scripts/deploy-production.sh
```

### Step 4 Add Storage
80GB General Purpose SSD (GP2)
Delete on Termination: Checked

### Step 5 Add Tags
Tags let us filter and group instances in the EC2 Dashboard.

 - Key: Name
 - Value: Maintenance

 - Key: Environment
 - Value: Production

### Step 6 Configure Security Group
This controls what ports are opened on the server + grants access to certain IP addresses

 - Assign a security group: Select an existing security group
 - [x] Prod - SSH Access (This grants SSH access from whitelisted IPs)
 - [x] Web Server - Prod - Spirited Media (Opens certain ports needed to serve traffic)


### Step 7 Review Instance Launch
Check over the settings. When you're ready, click the __Launch__ button to start your instance.

## SSH into the Maintence Box

 - While the EC2 instance is booting up, copy the public IPv4 IP address.
 - Edit your `hosts` file so our domain names point to the new instance instead of the load balancer. [Gas Mask](https://github.com/2ndalpha/gasmask) is handy for this.
 
 ``` 
 xxx.xxx.xxx.xxx    spiritedmedia.com billypenn.com www.billypenn.com billypenn.spiritedmedia.com theincline.com www.theincline.com theincline.spiritedmedia.com
```

It's helpful to have this in your `~/.ssh/config` file to make SSHing easier:

```
Host *
	IdentityFile ~/.ssh/id_rsa
	AddKeysToAgent yes

Host spiritedmedia.com
	HostName spiritedmedia.com
	Port 22
	User ubuntu
	IdentityFile ~/.ssh/spirited-media/EC2-Prod-SpiritedMedia.pem
	StrictHostKeyChecking no
	UserKnownHostsFile=/dev/null
```

- SSH into the box, `ssh spiritedmedia.com`

## Make Changes
Hooray you're in! Now you can muck about and make any changes you need. 

### To update WordPress to the latest version
`sudo wp core update --allow-root` 

### Upgrade OS/server patches
Run `./update-os.sh` from `~`.
Baby sit the prompt and keep any local configurations if prompted.

### Sync S3 Media to Local Server
If S3 should ever die, we will have a last-ditch-effort backup of all our media uploads because we periodically sync them back to the local server image.

Go to `/var/www/spiritedmedia.com/scripts`. Run `sudo ./sync-s3-to-uploads.sh`. Wait while the media is compared and synced.

## Make a New AMI Image

 - Go to the [EC2 Dashboard](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1)
 - Select your maintenance server and select _Image_ --> _Create Image_ from the _Actions_ dropdown
 - Image name: `spiritedmedia.com-2017-03-07`
 - Image Description: `(Some sort of description about what was changed i.e. Updated WordPress to 4.7.3)`
 - Wait while AWS makes an image from the server

### Rename/Delete Old AMIs  
 - Go to the [AMIs section](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:sort=desc:name)
 - You should see your pedning AMI in the list without Name and Environment tags
 - Set the Name to `Latest`, Environment to `Production`
 - Rename the name of the previous Production AMI to `Backup`
 - Deregister the oldest backup by selecting _Deregister_ from the Actions menu after selecting the AMI

## Creating a New Launch Configuration
Launch configurations are associated with autoscaling groups. It tells the autoscale group the settings for new servers that should be spun up.

- Go to the [_Launch Configurations_ section](https://console.aws.amazon.com/ec2/autoscaling/home?region=us-east-1#LaunchConfigurations:) under _Auto Scaling_ in the left menu
- Select the latest Launch Configuration and select _Copy launch configuration_ from the Actions drop down
- Follow the steps for configuring a Launch Configuration. __Note:__ Many settings should be preset from copying a previous launch configuration.

### Step 1 Choose AMI
Choose the AMI we just created. New servers will be created based off of this image.

### Step 2 Choose Instance Type
Choose `t2.small` for production

### Step 3 Configure Details
```
Name: 2017-03-07 Production - Spirited Media

Purchasing option: Uncheck Request Spot Instances

IAM Role: CodeDeploy-EC2

Monitoring: Uncheck Enable CloudWatch detailed monitoring
```

#### Advanced Details
```
User Data: As Text

#!/bin/bash
source /var/www/spiritedmedia.com/scripts/deploy-production.sh

IP Address Type: Assign a public IP address to every instance.
```

### Step 4 Add Storage
Size: 80GB General Purpose (SSD)

### Step 5 Configure Security Group
This controls what ports are opened on the server + grants access to certain IP addresses

 - Assign a security group: Select an existing security group
 - [x] Prod - SSH Access (This grants SSH access from whitelisted IPs)
 - [x] Web Server - Prod - Spirited Media (Opens certain ports needed to serve traffic)

### Step 6 Review
Review your changes and click the __Create launch configuration__ button

### Delete the Oldest Launch Configuration
We always keep the latest launch configuration and the most recent backup. 

 - Go to the [Launch Configurations](https://console.aws.amazon.com/ec2/autoscaling/home?region=us-east-1#LaunchConfigurations:) screen
 - Select the oldest configuration and delete it from the Actions dropdown 

## Update the Auto Scaling Group
The autoscaling group controls when new servers need to be spun up when old servers die.

- Select the _Autoscale - Production - Spirited Media_ auto scaling group and click _Edit_
- Change the _Launch Configuration_ to the latest launch configruation we just created
- Click _Save_ to save our changes

## Repalce the Running Instances
We're going to one-by-one remove old instances and replace them with new instances using our latest AMI.

 - Go to the Instances tab of our Auto Scaling Group
 - Select a running instance and choose _Detach_ from the Actions dropdown
 - [x] _Add a new instance to the Auto Scaling group to balance the load_ from the modal
 - Click the _Detach Instance_ button
 
 AWS will remove the instance from the autoscaling group and spin up a new one to take its place. Monitor the progress of the new instance over in the [EC2 dashboard](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:sort=instanceState). 2/2 status checks need to be completed on the new instance before the instance will accept traffic. Once it is accepting traffic, replace the other, older instance from the autoscaling group.
 
## Delete Old Instances
When we're done with servers we need to kill them otherwise we will continue to be charged for them even if they are serving 0 traffic.

 - Go to the [EC2 dashboard](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:sort=instanceState)
 - Note the servers in the Production Environment that aren't part of the Autoscaling Group (You may need to enable columns by clicking the gear icon in the upper right)
- Select all servers that you want to terminate
- Choose _Instance State_ --> _Terminate_ from the Actions dropdown

You're basically done!

## Share the IPs of the New Instances with #product

- Go to the [EC2 dashboard](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:sort=instanceState)
- Note the IP addresses of the production servers in the Autoscaling Group
- Send the following message to the #product channel on Slack

```
# AWS Maintence
# xxx.xxx.xxx.xxx 	    spiritedmedia.com billypenn.com www.billypenn.com billypenn.spiritedmedia.com theincline.com www.theincline.com theincline.spiritedmedia.com
# xxx.xxx.xxx.xxx 	    spiritedmedia.com billypenn.com www.billypenn.com billypenn.spiritedmedia.com theincline.com www.theincline.com theincline.spiritedmedia.com
```

Update any IP addresses like Sequel Pro. 