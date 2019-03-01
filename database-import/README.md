# Importing a Database

When you need to refresh the content for your local site or the staging site you'll need to do a database dump from production. Which tables you need to grab depends on what you are trying to do.

Our method for getting the production database dump usually relies on adding the live database connection details to Sequel Pro and exporting from there. The dump can't be downloaded directly from AWS because we rely on snapshots (i.e. restore points), not automated backups.

## Updating Post Content

If you just need to update posts (Articles, links, embeds, Fact Checks, etc.) then export all of the tables except for the `wp_options` table for each site that you want. Importing a `wp_options` table will require extra cleanup.

## A Full Site Dump

If you need to import a fresh site dump then export all of the tables. There will be some changes that you will need to make:

For each site's `wp_options` table you will need to update the URLs. Failure to do this will cause WordPress to redirect to the live site.

 - Replace `https://new-domain.dev/` with the new domain name
 - Replace `https://old-domain.com` with the domain name of the live site (`https://billypenn.com/`, `https://theincline.com`)

_Note: In `wp_x_options` replace `x` with the proper site ID (like `wp_2_options` etc.)_

```
UPDATE `wp_x_options` SET `option_value` = 'https://new-domain.dev' WHERE `option_value` = 'https://old-domain.com';
```

**The trailing slashes matter in these queries!** `billypenn.com/` should have a trailing slash while none of the other URLs should have a trailing slash. This likely has something to do with Billy Penn being created as a single site originally, with the other sites added as new sites once Billy Penn was converted to a site on a multisite network.

Replace the values in the `domain` column in the `wp_blogs` table.

If you're doing a dump for a new developer, add them to the production sites first then do the dump. It's just easier that way.

If you're locked out and can't login you will need to reset your password. Relying on the password reset link to be emailed to you can be unreliable. See the [Reset Password](https://codex.wordpress.org/Resetting_Your_Password) section of the Codex or get the MD5 hash of a string and replace the `user_pass` field for your user ID in the `wp_users` table. Once you log in WordPress will convert the MD5 hash to a more secure hash.

## Cleanup SQL Commands

After doing a database dump run the following SQL commands in the Query Editor of Sequel Pro.

N.B. The trailing slashes matter in these queries! See note in the section above.

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
```

## Resources
 - [Official WordPress Database Schema](https://codex.wordpress.org/Database_Description)
 - [WordPress Multisite Database Tour](https://deliciousbrains.com/wordpress-multisite-database-tour/)
 - [WordPress Multisite Database Structure](https://rudrastyh.com/wordpress-multisite/database-tutorial.html)
