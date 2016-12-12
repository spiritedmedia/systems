# Amazon SES for Transactional Emails
aka How We Send Email from Our Servers

The [Amazon SES](https://aws.amazon.com/ses/) service handles sending out email on our behalf. They handle the messy details of actually sending the email. We handle making an API request thanks to [Humanmade's AWS SES wp_mail() drop-in](https://github.com/humanmade/aws-ses-wp-mail) plugin.

## Installation
 0. Humanmade's plugin has been added to our `composer.json` file
 - Network activate the plugin
 - Run `wp aws-ses verify-sending-domain` for each domain we want to send email from (This only needs to be done once per domain, not once per environment)
 - Send a test via WP CLI like `wp aws-ses send <to> <subject> <message> [--from-email=<email>]`

### Adding/verifying a new domain
0. Make sure the new email address is being returned from filtering `wp_mail_from` (Pedestal defaults to the `PEDESTAL_EMAIL_NEWS` constant)
- SSH into a server, run `wp aws-ses verify-sending-domain --url=<site_url>`
- Log on to the [AWS Console](http://aws.spiritedmedia.com)
- Verify the new domain name by adding DNS records to Route53. Details are in the AWS Console.
- You may need to [request your sending limit be increased](http://docs.aws.amazon.com/ses/latest/DeveloperGuide/increase-sending-limits.html)


## Pricing
Up to 62K email sent for free per month if done from an Amazon EC2 instance. Otherwise email messages are charged at $0.10 per 1,000 sent.