# Dynamic Image Resizing with Tachyon

We use a [forked version](https://github.com/spiritedmedia/tachyon) of [Tachyon](https://engineering.hmn.md/projects/tachyon/) from Humanmade to perform dynamic resizing of our images. 

## Problem
By default a theme/plugin defines image sizes that may be needed. When an image is uploaded to WordPress, the various image sizes are generated and saved to disk. If new image sizes are introduced previously uploaded images need to be regenerated so they have the proper sizes. With a media library in the thousands this takes a long time. The last time we did this it took about 2 days of crunching to convert all of our images to new sizes. This is not feasible as time goes on and our media library gets larger.

## Solution
With Tachyon, we can route requests to media library items through an API. The API will read the items out of an Amazon Web Services (AWS) S3 bucket and return them to the client. If the media item is an image we can manipulate it (resize, crop etc.) on the fly before returning the image back to the requester. Manipulating an image on demand is slower than simply fufilling a request from disk so we put a content delivery network (CDN) in front of the API to cache previously requested images. 

## Workflow
1. Images are uploaded to an S3 bucket via WordPress and the [WP Offload S3 Lite](https://wordpress.org/plugins/amazon-s3-and-cloudfront/) plugin
2. An AWS API Gateway service handles requests for static assets and passes them off to an AWS Lambda function 
3. An AWS Lambda function reads the requested file out of the S3 bucket and determines if any manipulation needs to be performed
	- If the file is an image then we can manipulate it using the [Sharp library](https://www.npmjs.com/package/sharp) before returning it back to the API gateway
	- If the file isn't an image then we simply return the file as it back to the API Gateway 
4. A CDN layer sits in front fo the AWS API Gateway to cache requests and speed up load times

## Differences in Our Fork
 - We added support for any type of file not just images. This way we only need one CDN URL for static assets. Files that aren't images just get returned as is while images can be manipulated (resized, cropped, etc.)
 - Updated the README.md file with better documentation of all of the query args for manipulating images.

## Local Development
To work with the Tachyon locally you need to perform the following steps:

1. Make sure you have Node 4.3+ installed
2. Install `libvips` on macOS: `brew install homebrew/science/vips --with-webp --with-graphicsmagick`
3. Clone the repo: `git@github.com:spiritedmedia/tachyon.git`
4. Install the node module dependencies: `npm install`
5. Populate the config.json with the AWS region and bucket name you want to use, in the following format:
```
{
	"region": "us-east-1",
	"bucket": "staging-spiritedmedia-com"
}
```
6. Start the server: `node server.js [port] [--debug]`
7. Visit http://localhost:8080/ to confirm it is working
8. Pass a path to a file in the bucket like http://localhost:8080/wp-content/themes/billy-penn/assets/images/young-penn.png?w=250 which should be resized to 250px wide

### Building the Docker Image and AWS Lambda Package
A docker file is included for building the node_modules for the AWS Lambda function. Follow these steps:

1. Download [Docker](https://www.docker.com/) and make sure it is running 
2. Run `npm run-script build-docker` to build the docker image (you only need to do this once)
3. Run `npm run-script build-node-modules` to compile the node modules for an Ubuntu Linux environment
4. Run `npm run-script build-zip` to build a zip file called `lambda.zip`
5. Upload `lambda.zip` to the `spiritedmedia-tachyon` bucket on S3
6. Update the lambda function via an S3 URL like https://s3.amazonaws.com/spiritedmedia-tachyon/lambda.zip