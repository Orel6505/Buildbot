# Buildbot.sh
Android Building Script - Script that can build for multiple devices

Please read the whole README before forking this repo

# DISCLAIMER
* This script is only for Linux Debian-based operating system.
* DO NOT use this script if you never built Android before
* I am not responsible for anything that may happen to your PC/phone by building/flashing
any custom ROMs using this script. (Bricked devices, dead SD cards, dead hard drives, CPU overheating,
GPU burning, thermonuclear war, Seal mad or you are getting fired because the alarm app
failed…)
* YOU are choosing to do these modifications, and you do it at your own risk.
if you point the finger at me or anyone else for messing up your device, you haven't
done what we told you to do.

# Prerequisites

1. Fork this repository. (Recommended & Optional)

2. Create a Telegram Bot. (Recommended & Optional)

3. Make a GitHub token with proper permissions for uploading releases to your repositories. (If you choosing to upload to GitHub)

4. Log in 1 time to normal sftp (`sftp username@frs.sourceforge.net`) before running script if you choosed to upload to Sourceforge (if you'll not log in once, it'll not upload it because you need to set "save fingerprint")

5. Create local_manifests repo in github and upload your manifest. (Required for `MANIFEST_URL`)

# How To Use This Script

1. Clone your fork of this repository.

2. Make your changes in `config.sh`.

3. run `first_time.sh` even if you already built Android on your PC before.

4. run `config.sh` to start the script.

# How to create local_manifests
See `https://github.com/Orel6505/local_manifests` for guide

# Configuration flags

`ROM_NAME` - name of your ROM ( For example `LineageOS`)

`ANDROID_VERSION` - Android version of your ROM ( For example `11`)

`REPO_URL` -  URL link to ROM manifest ( For example `https://github.com/LineageOS/android`)

`REPO_BRANCH` -  name of your ROM ( For example `lineage-18.1`)

`MANIFEST_URL` -  URL link to your manifest ( For example `https://github.com/Orel6505/local_manifests`)

`MANIFEST_BRANCH` -  manifest branch 

`DEVICE_CODENAME` - Device codenames (For example: `"beyond1lte"` for Samsung Galaxy S10, you can send more than 1 device (don't forget to include them in your manifest). for example: `"beyond0lte beyond1lte beyond2lte"`)

`LUNCH_NAME` - ROM's custom lunch name (For example: `lineage` from `lineage_beyond1lte-userdebug`)

`AUTO_BRINGUP` - this feature will bring up your device tree from lineage_beyond1lte to aosp_beyond1lte automatically (`Y` to enable, `N` to disable)

`BACON_NAME` - ROM's custom bacon name (For example: most of the roms using `bacon`)

`UPLOAD_TYPE` -`GD` for Gdrive, `SF` for SourceForge `FTP` for FTP, `GH` for Github and `OFF` for disable upload

`UPLOAD_RECOVERY` - Do you want to upload recovery.img?

`BUILD_TYPE` - Describe for what purpose this build (For example: `Test`)

`SF_USER` -  your SourceForge username (for example `Orel6505`)

`SF_PASS` -  your SourceForge password (not ssh)

`SF_PROJECT` - SourceForge project name you want to upload to (For example: `orel6505-builds`)

`SF_PATH` - (Optional, the default upload path `orel6505-builds/(codename)`, leave blink if you want to upload to the default path) different upload path for sourceforge (For example: `test` for uploading to test folder)

`GD_PATH` - Gdrive upload path id (for example: `1-04oC14tCH6vPsaMd5_bRnfLWI9Te6hA`, you can found it after the url `https://drive.google.com/drive/folders/1-04oC14tCH6vPsaMd5_bRnfLWI9Te6hA`. DO NOT set in to: for example "Test" it WONT WORK.)

`GH_USERNAME` - your GitHub username (for example `Orel6505`)

`GH_REPO` - your Github releases repo (you can use any repo for releases)

`TG_TOKEN` - your Telegram bot token (for Example `123456:AbcDefGhi-JklMnoPrw`)

`TG_CHAT` - your Telegram group id (add `@missrose_bot` to your group and send `/id` to see your group id)
