# Getting Code From Local To Production

GitHub Repo --> CircleCI --> Build-specific GitHub Repo --> AWS CodePipeline --> AWS CodeDeploy --> Notifications

## GitHub Repo
Code changes are committed to a GitHub repo. When the changes are merged into the `staging` branch or a release tag is created, [CircleCI](../circleci/README.md) will be notified.

## CircleCI
See [CircleCI section](circleci/).

## Build-specific GitHub Repo
Once CircleCI finishes building the repo, the full set of changes are committed to a separate repo automatically. Keeping finished builds in Git allows us to easily pull down changes on the servers, easily ignore certain directories, and add/remove files as necessary. Weaving additions and deletions into WordPress' folder structure is tricky using other tools like [rsync](https://en.wikipedia.org/wiki/Rsync).

To make sure files that are ignored in the repo are added to the build-repo a build-specific `.gitignore` file is used named `.gitignore-build`

### Difference between Repo and build-specific Repo
 - Compiled CSS files are committed
 - Minified and concatenated JavaScript files are committed
 - Composer `/vendor/` and `autoload.php` file are committed
 - Package-manager specific files, linters, .git files are ignored, since they're not needed


## AWS CodePipeline
[AWS CodePipeline](https://console.aws.amazon.com/codepipeline/home?region=us-east-1#/dashboard) monitors the build repo for changes and triggers AWS CodeDeploy to run. 

## AWS CodeDeploy
[AWS CodeDeploy](https://console.aws.amazon.com/codedeploy/home?region=us-east-1#/applications) handles updating servers with the latest code changes. Servers can be identified for a deployment by tags or by a specific auto scaling group. The AWS CodeDeploy agent must be [installed](http://docs.aws.amazon.com/codedeploy/latest/userguide/how-to-set-up-new-instance.html) on EC2 instances for this to work.

An [appsec.yml](http://docs.aws.amazon.com/codedeploy/latest/userguide/app-spec-ref.html) file in the repo details what should happen on the servers to load the latest code changes. Our appsec.yml file simply calls a shell script to perform a `git pull` to pull down the latest changes on each of the running instances.

The appsec.yml file prohibits calling arbitrary scripts. A stub shell script is included in the repo at `/bin/codedeploy.sh`. This shell script downloads and executes the shell script specified in the [EC2 instance User Data field](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html). The user data shell script calls the deploy script baked in to the AMI running the server.

## Notifications

Event notifications are sent to [Slack via an AWS Lambda function](https://medium.com/cohealo-engineering/how-set-up-a-slack-channel-to-be-an-aws-sns-subscriber-63b4d57ad3ea) when a deploy starts, fails, or succeeds. 

