# Virtual Private Clouds (VPCs)
Virtual Private Clouds are like bubbles around our infrastructure. This keeps our resources private from other resources of AWS customers as well as allowing us to specify rules to allow or deny connections to our resources. VPCs can span multiple availability zones (separate data centers within an AWS region). Production and staging environments are in separate VPCs so they don't mess with each other. 

Our VPCs are setup with an IPv4 CIDR block of `10.0.0.0/16` (This determines how many IP addresses are available for the private network. See <https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html#vpc-sizing-ipv4>)

## Subnets

We have two types of subnets: public and private.

*Public subnets* mean the machines are accessible through the Internet including load balancers and web servers.

*Private subnets* have no access to the Internet but can talk to other machines through the local network. Things like database servers should live in private subnets.

Our subnets are derived of the 10.0.x.0/24 CIDR block with 251 IPs available per subnet. Odd numbers are private subnets, even numbers are public subnets.

To make a subnet public you need to attach an [Internet Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html) via a [Route Table](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html).

### Details

Production

 - VPC: Prod - Spirited Media
   - 10.0.1.0/24 Private (us-east-1b)
   - 10.0.2.0/24 Public (us-east-1b)
   - 10.0.3.0/24 Private (us-east-1c)
   - 10.0.4.0/24 Public (us-east-1c)

Staging

 - VPC: Stage - Spirited Media
 	- 10.0.2.0/24 Public (us-east-1d)
