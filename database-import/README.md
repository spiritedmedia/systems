# Importing a Database

When you need to refresh the content for your local site or the staging site
you'll need to do a database dump from production. Which tables you need to grab
depends on what you are trying to do.

Our method for getting the production database dump usually relies on adding the
live database connection details to Sequel Pro and exporting from there. The
dump can't be downloaded directly from AWS because we rely on snapshots (i.e.
restore points), not automated backups.

## Updating Post Content

If you just need to update posts (Articles, links, embeds, Fact Checks, etc.)
then export all of the tables except for the `wp_x_options` table (where `x` is
the site ID) for each site that you want. Importing a `wp_x_options` table will
require extra cleanup.

## A Full Site Dump

If you're doing a dump for a new developer, add them to the production sites
first then do the dump. It's just easier that way.

If you need to import a fresh site dump then export all of the tables. Then run
the following SQL commands in the Query Editor of Sequel Pro.

- For each site's `wp_x_options` table you will need to update the URLs (where
  `x` is the site ID). Failure to do this will cause WordPress to redirect to
  the live site.
- Replace the values in the `domain` column in the `wp_blogs` table.
- Clear out any MailChimp settings in the `wp_x_options` tables (where `x` is
  the site ID).

**The trailing slashes matter in these queries!** `billypenn.com/` should have a
trailing slash while none of the other URLs should have a trailing slash. This
likely has something to do with Billy Penn being created as a single site
originally, with the other sites added as new sites once Billy Penn was
converted to a site on a multisite network.

### For Production --> Local

```
# Update domains in the wp_x_options tables
UPDATE `wp_options` SET `option_value` = 'https://spiritedmedia.dev' WHERE `option_value` = 'https://spiritedmedia.com';
UPDATE `wp_2_options` SET `option_value` = 'https://billypenn.dev/' WHERE `option_value` = 'https://billypenn.com/';
UPDATE `wp_3_options` SET `option_value` = 'https://theincline.dev' WHERE `option_value` = 'https://theincline.com';
UPDATE `wp_4_options` SET `option_value` = 'https://denverite.dev' WHERE `option_value` = 'https://denverite.com';

# Update domains in wp_blogs
UPDATE `wp_blogs` SET `domain` = 'spiritedmedia.dev' WHERE `domain` = 'spiritedmedia.com';
UPDATE `wp_blogs` SET `domain` = 'billypenn.dev' WHERE `domain` = 'billypenn.com';
UPDATE `wp_blogs` SET `domain` = 'theincline.dev' WHERE `domain` = 'theincline.com';
UPDATE `wp_blogs` SET `domain` = 'denverite.dev' WHERE `domain` = 'denverite.com';

# Clear MailChimp groups settings
DELETE FROM `wp_2_options` WHERE `option_name` LIKE 'mailchimp%';
DELETE FROM `wp_3_options` WHERE `option_name` LIKE 'mailchimp%';
DELETE FROM `wp_4_options` WHERE `option_name` LIKE 'mailchimp%';
```

### For Production --> Staging
```
# Update domains in the wp_x_options tables
UPDATE `wp_options` SET `option_value` = 'https://staging.spiritedmedia.com' WHERE `option_value` = 'https://spiritedmedia.com';
UPDATE `wp_2_options` SET `option_value` = 'https://staging.billypenn.com/' WHERE `option_value` = 'https://billypenn.com/';
UPDATE `wp_3_options` SET `option_value` = 'https://staging.theincline.com' WHERE `option_value` = 'https://theincline.com';
UPDATE `wp_4_options` SET `option_value` = 'https://staging.denverite.com' WHERE `option_value` = 'https://denverite.com';

# Update domains in wp_blogs
UPDATE `wp_blogs` SET `domain` = 'staging.spiritedmedia.com' WHERE `domain` = 'spiritedmedia.com';
UPDATE `wp_blogs` SET `domain` = 'staging.billypenn.com' WHERE `domain` = 'billypenn.com';
UPDATE `wp_blogs` SET `domain` = 'staging.theincline.com' WHERE `domain` = 'theincline.com';
UPDATE `wp_blogs` SET `domain` = 'staging.denverite.com' WHERE `domain` = 'denverite.com';

# Clear MailChimp groups settings
DELETE FROM `wp_2_options` WHERE `option_name` LIKE 'mailchimp%';
DELETE FROM `wp_3_options` WHERE `option_name` LIKE 'mailchimp%';
DELETE FROM `wp_4_options` WHERE `option_name` LIKE 'mailchimp%';
```


### Isolating Individual Sites

If you only need one particular site, you can clear out the posts, postmeta, and
some other heavy tables for the sites you don't need. But make sure to leave the
tables intact, deleting only the rows.

N.B. The `wp_x_options` tables for each site should remain untouched.

For example, if you only need data for Denverite, you can run the following,
where `wp_2_` is the prefix for Billy Penn and `wp_3_` is the prefix for The
Incline:

```sql
DELETE FROM `wp_2_p2p`;
DELETE FROM `wp_2_p2pmeta`;
DELETE FROM `wp_2_postmeta`;
DELETE FROM `wp_2_posts`;
DELETE FROM `wp_2_redirection_404`;
DELETE FROM `wp_2_redirection_groups`;
DELETE FROM `wp_2_redirection_items`;
DELETE FROM `wp_2_redirection_logs`;
DELETE FROM `wp_2_term_relationships`;
DELETE FROM `wp_2_term_taxonomy`;
DELETE FROM `wp_2_termmeta`;
DELETE FROM `wp_2_terms`;
DELETE FROM `wp_3_p2p`;
DELETE FROM `wp_3_p2pmeta`;
DELETE FROM `wp_3_postmeta`;
DELETE FROM `wp_3_posts`;
DELETE FROM `wp_3_redirection_404`;
DELETE FROM `wp_3_redirection_groups`;
DELETE FROM `wp_3_redirection_items`;
DELETE FROM `wp_3_redirection_logs`;
DELETE FROM `wp_3_term_relationships`;
DELETE FROM `wp_3_term_taxonomy`;
DELETE FROM `wp_3_termmeta`;
DELETE FROM `wp_3_terms`;
```


### Adding A New Super-Admin Manually

If you need to add yourself as a Super-Admin to an existing database, or for
some reason you can't or prefer not to add a new user to the production site
before exporting it, this section is for you.

SSH into the server with `ssh <host>` or `vagrant ssh`. Then run the following
commands, replacing the values as needed:

```sh
# Replace `<network-domain-name>` with the appropriate value for the environment
# you're working with.
#
# Local: `spiritedmedia.dev`
# Staging: `staging.spiritedmedia.com`
# Production: `spiritedmedia.com`
cd /var/www/<network-domain-name>/htdocs/

wp user create <username> <email> --role=administrator
wp super-admin add <username>

# You'll probably also want to give your new user a role on each site. Run the
# following command for each site, replacing `site-url` as needed.
wp --url=<site-url> user set-role <username> administrator
```

You should then be able to log into the site with the username and password
output from the `wp user create` command.


### Common Issues

If you're locked out and can't login, try clearing all saved cookies for each
site, as they might have become invalid after importing a new database. If
clearing cookies doesn't work, you will need to reset your password. Relying on
the password reset link to be emailed to you can be unreliable. See the [Reset Password](https://codex.wordpress.org/Resetting_Your_Password) section of the
Codex or get the MD5 hash of a string and replace the `user_pass` field for your
user ID in the `wp_users` table. Once you log in WordPress will convert the MD5
hash to a more secure hash.

If you're getting redirected to the live sites after running these queries, run
`wp cache flush` in the web root directory to flush the object cache. If you see
a "Site not found" error after replacing a domain, try flushing cache against
the old domain (which may be the cached lookup value).

## Resources
 - [Official WordPress Database Schema](https://codex.wordpress.org/Database_Description)
 - [WordPress Multisite Database Tour](https://deliciousbrains.com/wordpress-multisite-database-tour/)
 - [WordPress Multisite Database Structure](https://rudrastyh.com/wordpress-multisite/database-tutorial.html)
