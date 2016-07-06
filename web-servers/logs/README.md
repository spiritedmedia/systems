# Logs

Analyzing access logs can be helpful for identifying aggressive visitors. [GoAccess](https://goaccess.io/) is a command line tool that provides a pretty interface for analyzing logs on a server. 

## Installation

Do not install via apt-get as this is an old version. Instead add the Official GoAccess' Debian/Ubuntu Repository and install that way. See [GoAccess' Download page](https://goaccess.io/download).

## Log Format
EasyEngine uses a custom log format that we need to tell GoAccess about.

`%h %D %^ [%d:%^] %^ "%r" %s %b "%R" "%u"`

This can be defined in a configuration file in `/etc/goaccess.conf`

See [this GitHub issue](https://github.com/EasyEngine/easyengine/issues/481#issuecomment-89288098) 

## How to Use on the Command Line

You can SSH to a server and view logs in real-time. Use the following command:

`sudo goaccess -f /var/www/staging.spiritedmedia.com/logs/access.log`

`-f` tells `goaccess` the path to the log file to analyze.

![goaccess-command-line-ui](https://cloud.githubusercontent.com/assets/867430/16627163/0dea5206-437a-11e6-802e-53c4836298ba.png)

## How to View An HTML Report

GoAccess can generate an HTML report that can be viewed from a browser. The report needs to be manually generated from the server. 

1. SSH into the server
2. Run `. /var/www/staging.spiritedmedia.com/scripts/generate-stats.sh`
3. Visit <http://staging.spiritedmedia.com/stats/> to view the stats

![goaccess-html-report](https://cloud.githubusercontent.com/assets/867430/16627129/e91f6718-4379-11e6-8125-514b82606536.png)

*Note: This is currently only set-up on staging.spiritedmedia.com Setting this up on the live servers would require syncing logs to one central location.*