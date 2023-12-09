#!/bin/bash

#
# Copyright (C) 2022 Orel6505
#
# SPDX-License-Identifier: GNU General Public License v3.0
#

## Need To Fill
#Sync - Required
ROM_NAME=""
ANDROID_VERSION=""
REPO_URL=""
REPO_BRANCH=""
MANIFEST_URL=""
MANIFEST_BRANCH=""

#Build - Required
DEVICE_CODENAME=""
AUTO_ADAPT=""
LUNCH_NAME=""
BACON_NAME=""
SYNC_BEFORE_BUILD="" #True by default
BUILD_J="" #default by default - don't know what does that mean? ask google "make -j"

#Upload stuff - Optional
UPLOAD_TYPE=""
UPLOAD_RECOVERY=""
TG_USER=""

#Telegram - Optional
TG_TOKEN=""
TG_CHAT=""
TG_TOPIC=""

#Github Releases & OTA - Optional
GH_USER=""
GH_TOKEN=""
GH_REPO_URL=""
OTA_JSON=""
OTA_LIKE="" #LOS/PE/crDroid/Evox
CUSTOM_ROM_ZIP_DOWNLOAD_URL="" #Mainly for FTP and gdrive users
MAINTAINERS="" #PE and Evox specific
XDA_TREAD="" #PE and Evox specific
DONATE_URL="" #PE and Evox specific
NEWS_URL="" #PE and Evox specific
WEBSITE_URL="" #PE and Evox specific
GH_MAINTAINERS="" #for PixelExperience only
MAINTAINER_URL="" #evox specific
BUILD_TYPE="" #crDroid specific
FIRMWARE_URL="" #crDroid specific
MODEM_URL="" #crDroid specific
BOOTLOADER_URL="" #crDroid specific
RECOVERY_URL="" #crDroid specific

#SourceForge - Optional
SF_USER=""
SF_PASS=""
SF_PROJECT=""
SF_PATH=""

#FTP - Optional
FTP_USER=""
FTP_PASS=""
FTP_UPLOAD_URL=""

source build.sh
