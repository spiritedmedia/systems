<?php
// ** MySQL settings ** //

/** The name of the database for WordPress */
define('DB_NAME', '');

/** MySQL database username */
define('DB_USER', '');

/** MySQL database password */
define('DB_PASSWORD', '');

/** MySQL hostname */
define('DB_HOST', '');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

define('AUTH_KEY',         '');
define('SECURE_AUTH_KEY',  '');
define('LOGGED_IN_KEY',    '');
define('NONCE_KEY',        '');
define('AUTH_SALT',        '');
define('SECURE_AUTH_SALT', '');
define('LOGGED_IN_SALT',   '');
define('NONCE_SALT',       '');


$table_prefix = 'wp_';

define( 'WPMU_ACCEL_REDIRECT', true );
define( 'WP_AUTO_UPDATE_CORE', false );
define( 'DISALLOW_FILE_MODS', true );
define( 'DISABLE_WP_CRON', true );
define( 'WP_POST_REVISIONS', 30 );

if ( isset( $_GET['debug'] ) && $_GET['debug'] == '' ) {
    define('WP_DEBUG', true);
}
if ( defined('WP_DEBUG') && constant('WP_DEBUG') ) {
    define( 'WP_DEBUG_DISPLAY', true );
}

$redis_server = array(
    'host' => '',
    'port' => 6379,
);

// S3 User access keys for WP Offload S3 Lite
define( 'DBI_AWS_ACCESS_KEY_ID', 'AKIAJ3DJW6ZQMCOWQC5Q' );
define( 'DBI_AWS_SECRET_ACCESS_KEY', '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' );

// AWS API Keys for AWS SES wp_mail() drop-in
define( 'AWS_SES_WP_MAIL_REGION', 'us-east-1' );
define( 'AWS_SES_WP_MAIL_KEY', 'AKIAJOACBN3CBCNTVLMA' );
define( 'AWS_SES_WP_MAIL_SECRET', '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' );

// ActiveCampaign API Credentials
define( 'ACTIVECAMPAIGN_URL', 'https://spiritedmedia.api-us1.com' );
define( 'ACTIVECAMPAIGN_API_KEY', '1b58c423bdc83f0a2da862a8b54d216a15dcc247b954b3d2fd8f414b835d09fb0696f5a8' );

// YouTube Data API Key
define( 'YOUTUBE_DATA_API_KEY', 'AIzaSyAiTWBODuombS_Xwax2ZzZbisskVnsw3ag' );

# For the Mercator Domain Mapping plugin
define( 'SUNRISE', 'on' );

define( 'WP_ALLOW_MULTISITE', true );
define( 'MULTISITE', true );
define( 'SUBDOMAIN_INSTALL', true );
$base = '/';
define( 'DOMAIN_CURRENT_SITE', 'spiritedmedia.com' );
define( 'PATH_CURRENT_SITE', '/' );
define( 'SITE_ID_CURRENT_SITE', 1 );
define( 'BLOG_ID_CURRENT_SITE', 1 );

if ( ! empty( $_SERVER['HTTP_X_FORWARDED_FOR'] ) ) {
    /*
    Set $_SERVER variables if the request is being passed from an HTTPS request from the load balancer. Otherwise is_ssl() doesn't work and we get endless redirects
    */
    if ( 'https' === $_SERVER['HTTP_X_FORWARDED_PROTO'] ) {
      $_SERVER['HTTPS'] = 'on';
      $_SERVER['SERVER_PORT'] = '443';
    }

	/*
    Set $_SERVER['REMOTE_ADDR'] to the real IP address of the requester
    See https://core.trac.wordpress.org/ticket/9235#comment:40
    */
    $parts = explode( ',', $_SERVER['HTTP_X_FORWARDED_FOR'] );
    $_SERVER['REMOTE_ADDR'] = $parts[0];
    unset( $parts );
}


/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
        define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');


// define( 'WP_CACHE_KEY_SALT', 'spiritedmedia.com:' );
