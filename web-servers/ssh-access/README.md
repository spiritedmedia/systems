# Create Certificates for accessing our EC2 and RDS Instances

We have two mechanisms in place for protecting our resources: 1) IP Whitelisting and 2) Passwordless Key Pair authentication.

## IP Whitelisting

We setup SSH access via a security group for each environment. Before trying to SSH into a server your IP address needs to be whitelisted. 

 - Go to https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#SecurityGroups
 - Find the security groups for SSH access (one for the staging environment, one for the production environment)
 - Go to the _Inbound_ tab 
 - Click the _Edit_ button
 - Make your changes and save (changes should take effect right away)

## Generating a Key Pair

Key pairs have two parts: a public key stored on the server when launching an EC2 instance and a private key that you download to your local machine. When those two match, you are granted access. 

 - Visit https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#KeyPairs
 - Give it a name like `EC2 - Stage - Spirited Media` or `EC2 - Prod - Spirited Media` (Each environment should have its own keypair)
 - A `pem` file will be downloaded, save this in a safe place. Without it we can't access our servers.
 - Move the `pem` file to your `.ssh` directory on your local machine
 - Change permissions so only the root user can read it `chmod 400 ~/.ssh/path/to/pem-file.pem`
 - Edit your `.ssh/config` file so it always uses the certificate when trying to connect over SSH
 ```
 Host spiritedmedia.com
	HostName spiritedmedia.com
	Port 22
	IdentityFile ~/.ssh/spirited-media/EC2-Prod-SpiritedMedia.pem
	StrictHostKeyChecking no
	UserKnownHostsFile=/dev/null
```
 
 See <https://unix.stackexchange.com/a/115860>
 
## Connecting to a Database

Connecting to the production database directly is not possible. You need to connect via an SSH tunnel through an EC2 instance and then to the database. In Sequel Pro the details are as follows:

 - SSH Host: (IP address of EC2 instance)
 - SSH User: (usually `ubuntu`)
 - SSH Key: (Path to the private key on your local machine) 