# Details

## Production
 - VPC: Prod - Spirited Media
   - 10.0.1.0/24 Private (us-east-1b)
   - 10.0.2.0/24 Public (us-east-1b)
   - 10.0.3.0/24 Private (us-east-1c)
   - 10.0.4.0/24 Public (us-east-1c)

## Staging
 - VPC: Stage - Spirited Media
 	- 10.0.2.0/24 Public (us-east-1d) 

# Virtual Private Clouds (VPCs)
Virtual Private Clouds are like bubbles around our infrastructre. This keeps our resources private from other resources of AWS customers as well as allowing us to specify rules to allow or deny connections to our resources. VPCs can span multiple availability zones (separate data centers within an AWS region). Production and staging environments are in separate VPCs.

# Subnets

We have two types of subnets: public and private.

*Public subnets* mean the machines are accessible through the Internet including load balancers and web servers. 

*Private subnets* have no access to the Internet but can talk to other machines through the local network. Database servers should live in a private subnet.

Our subnets are derived of the 10.0.x.0/24 CIDR block with 251 IPs available per subnet. Odd numbers are private subnets, even numbers are public subnets.