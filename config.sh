#!/bin/bash

#
# Orel6505
#

## Need To Fill
#Sync - Requierd
ROM_NAME=""
REPO_URL=""
REPO_BRANCH=""
MANIFEST_URL=""
MANIFEST_BRANCH=""

#Build - Requierd 
DEVICE_CODENAME=""
LUNCH_NAME=""
BACON_NAME=""

#Upload stuff - Optional
UPLOAD_TYPE=""
BUILD_TYPE=""
ANDROID_VERSION=""

#Google drive - Optional
GD_PATH="rom/Test"

#Github releases - Optional
GH_USERNAME=""
GH_REPO=""

#sourceforge
SF_USER="<your username here>"
SF_PROJECT="<project _name here>"
SF_PASS=<sourceforge password needs to be passed in this variable u can do it in your way>

#Telegram - Requierd for now
TELEGRAM_USERNAME=""
TELEGRAM_TOKEN=""
TELEGRAM_CHAT=""

source build.sh
