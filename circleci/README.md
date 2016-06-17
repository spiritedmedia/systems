# CircleCI

[CircleCI](https://circleci.com/dashboard) handles our build requirements before deploying code live. Tasks include
 
 - Compiling Sass to CSS
 - Concatenating & minifing JavaScript and CSS
 - Code linting
 - Adding approrpriate vendor prefixes to CSS properties

## Project Set Up
 
Almost all of the configuration for CircleCI is handled in the [circle.yml](https://circleci.com/docs/config-sample/) file in the root of the repo to be built. 
 
When setting up a new build you can add environment variables by going to the build's settings screen. Look for _Environment Variables_ under the _Build Settings_ section. The following environment variables are needed for our `deploy.sh` script:

0. DEPLOY_REPO_URL : The repo to commit the build to. Should be the SSH version not the HTTPS link to the repo i.e. `git@github.com:spiritedmedia/pedestal-beta-build.git`

### Access Keys
Keys are tricky. We need read access from the source repo and read/write access for the build repo. More TKTK.

## How does it work?

The circle.yml file tells CircleCI which build tools to install and which commands to run to perform the build process. The deployment section determines the logic for when and where a build should be deployed.

This repo is cloned and a shell script is run depending on the branch being built. The gist of the shell script is to remove a few uncessary files and commit the changes to a separate repo so the build can easily be pulled down to servers.

### Deploying to Production
 - Remove the `node_modules` directory. It's big and we don't need it to serve the websites.
 - Remove the `.gitignore` and replace it with the `.gitignore-build` version. The build version lets us commit compiled assets like CSS and JavaScript.
 - Remove the `README.md` file in the root of the repo and replace it with a generated one containing various build stats. 
 - Clone the build repo and commit our new build. 
 - Force push our changes back to the repo to avoid any merge conflicts. 
 - AWS CodePipeline will take over to deploy the changes to the production servers.

## Related Reading

 - [Automate everything with CircleCI](http://frankiesardo.github.io/posts/2015-04-19-automate-everything-with-circleci.html)