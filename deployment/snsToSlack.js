/*
This is a Node script to take an Amazon SNS message and broadcast it to a Slack channel.
See https://medium.com/cohealo-engineering/how-set-up-a-slack-channel-to-be-an-aws-sns-subscriber-63b4d57ad3ea
*/

var https = require('https');
var util = require('util');

exports.handler = function(event, context) {
   console.log(JSON.stringify(event, null, 2)); // For debugging via CloudWatch
    var jsonString = event.Records[0].Sns.Message;
    // If it's not valid JSON data then bail. Who cares...
    try {
        var data = JSON.parse( jsonString );
    } catch (e) {
        console.log( "Not a JSON message..." );
        return false;
    }

    var status = data.status;
    var appName = data.applicationName;
    var deployName = data.deploymentGroupName;

    var postData = {
        "channel": "#prd-botcountry",
        "username": "AWS CodeDeploy",
        "text": "*" + event.Records[0].Sns.Subject + "*",
        "icon_emoji": ":truck:"
    };

    var message = event.Records[0].Sns.Message;
    var slackMessage = "¯\\_(ツ)_/¯";
    var severity = "warning";

    if( status == 'SUCCEEDED' ) {
        var startTime = new Date( data.createTime );
        var endTime = new Date( data.completeTime );
        var duration = endTime.getSeconds() - startTime.getSeconds();
        var deployment = JSON.parse( data.deploymentOverview );

        if ( deployName == 'Production' ) {
            postData.channel = '#prd-backchannel';
        }
        postData.text = "*" + appName + " successfully deployed to " + deployName + " in " + duration + " seconds!*";
        if ( deployName == 'Production' ) {
            postData.text += "\n:siren_flashing: :siren_flashing: :siren_flashing: <@here> Someone run the post-deployment checklist: https://github.com/spiritedmedia/spiritedmedia/blob/master/qa/checklists/checklist-post-deployment.md";
        }
        severity = "good";
        slackMessage = "";
        for( var key in deployment ) {
            var val = deployment[key];
            slackMessage += key + ": " + val + "\n";
        }
    }

     if( status == 'CREATED' ) {
        if ( deployName == 'Production' ) {
            postData.channel = '#prd-backchannel';
        }
        postData.text = "*Deployment to " + appName + "/" + deployName + " has started...*";
        slackMessage = '';
     }

    postData.attachments = [
        {
            "color": severity,
            "text": slackMessage
        }
    ];

    // See https://slack.com/apps/A0F7XDUAZ-incoming-webhooks to get the correct path value
    var options = {
        method: 'POST',
        hostname: 'hooks.slack.com',
        port: 443,
        path: '/services/xxx/xxx/xxx'
    };

    var req = https.request(options, function(res) {
      res.setEncoding('utf8');
      res.on('data', function (chunk) {
        context.done(null);
      });
    });

    req.on('error', function(e) {
      console.log('problem with request: ' + e.message);
    });

    req.write(util.format("%j", postData));
    req.end();
};
