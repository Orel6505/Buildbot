#!/bin/bash

#
# Copyright (C) 2022 Orel6505
#
# SPDX-License-Identifier: GNU General Public License v3.0
#

## Need To Fill
#Sync - Requierd
ROM_NAME=""
ANDROID_VERSION=""
REPO_URL=""
REPO_BRANCH=""
MANIFEST_URL=""
MANIFEST_BRANCH=""

#Build - Requierd 
DEVICE_CODENAME=""
AUTO_BRINGUP=""
LUNCH_NAME=""
BACON_NAME=""

#Upload stuff - Optional
UPLOAD_TYPE=""
UPLOAD_RECOVERY=""
TG_USER=""

#Google Drive - Optional
GD_PATH=""

#Github Releases - Optional
GH_USERNAME=""
GH_REPO=""

#SourceForge - Optional
SF_USER=""
SF_PASS=""
SF_PROJECT=""
SF_PATH=""

#FTP - Optional
FTP_USER=""
FTP_PASS=""
FTP_UPLOAD_URL=""

#Telegram - Optional
TG_TOKEN=""
TG_CHAT=""

source build.sh