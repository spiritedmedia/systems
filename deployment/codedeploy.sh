#!/bin/bash
# The appsec.yml file prohibits calling arbitrary scripts. This stub shell script
# downloads and executes the shell script specified in the EC2 instance User Data field.
# The user data shell script calls the deploy script baked in to the AMI running on the server.

# Fetch the user data script associated with this type of instance and save it into a temporary shell script
curl http://169.254.169.254/latest/user-data > temp.sh

# Execute the shell script to run the update
bash temp.sh

# Clean up
rm temp.sh
