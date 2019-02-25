# Running An External Cron

WordPress' internal cron system is reliant upon actual visits to the site. Since we have full page caching in place, scheduled events that need to take place during low traffic periods (like the middle of the night) may not get fired.

We used to use WP CLI to run our cron tasks every minute but in production we run multiple servers. Each server is set to run the cron script every minute which results in duplicate cron events being run. This is not ideal.

We use AWS CloudWatch and a Lambda function to run an external cron job. In CloudWatch you can create rules to invoke Targets based on Events happening in your AWS environment. We setup a new rule called `every-minute` that runs at a fixed rate of once per minute. This triggers an AWS Lambda function that makes a request to `/multisite-cron.php` which runs any scheduled cron tasks in WordPress once.

See https://github.com/spiritedmedia/spiritedmedia/pull/2548
