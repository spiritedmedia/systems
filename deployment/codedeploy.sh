#!/bin/bash

# Fetch the user data script associated with this type of instance and save it into a temporary shell script
curl http://169.254.169.254/latest/user-data > temp.sh

# Execute the shell script to run the update
bash temp.sh

# Clean up
rm temp.sh
