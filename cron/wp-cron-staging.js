exports.handler = function(event, context, callback) {
    const https = require('https');

    // Get current time as seconds since epoch
    var d = new Date();
    var seconds = Math.round(d.getTime() / 1000);

    // Use dynamic query string to prevent caching
    var url = 'https://spirited:media@staging.spiritedmedia.com/multisite-cron.php?date=' + seconds;
    https.get(url, function(res) {
      console.log('statusCode:', res.statusCode);
      console.log('headers:', res.headers);
      callback(null, 'OK');

    }).on('error', function(err) {
      console.error(err);
      callback(null, 'BAD');
    });
};
