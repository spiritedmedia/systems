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

  	
