# Route 53
For all of the DNS stuff

Route 53 is Amazon's DNS service. Unlike other DNS providers, Route 53 can do dynamic records like _alias records_. 

Normally you need to specify a single IP address for an A record. If you have multiple IP addresses that could resolve a request (for redundancy) then you would normally have to use a CNAME record (aka a subdomain like www.example.com and not example.com). But thanks to Route 53's alias records we can have https://billypenn.com point to a load balanacer without needing to set the site URL to https://www.billypenn.com 

Outside of Alias Records our use of Route 53 is pretty bare bones: editing records for different domains.

## Tools for Checking DNS Propigation
 - https://www.whatsmydns.net/
 - https://dns.google.com/