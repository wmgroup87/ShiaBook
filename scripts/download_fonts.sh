#!/bin/bash

# Create fonts directory if it doesn't exist
mkdir -p assets/fonts

# Download Uthmanic Hafs font
curl -L -o assets/fonts/uthmanic_hafs_ver09.otf https://github.com/aracnix/uthmanic-hafs/raw/master/fonts/uthmanic_hafs_ver09.otf

echo "Fonts downloaded successfully!"
