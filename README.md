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

1. Fork this repository.

2. Create a Telegram Bot. (Required for now) 

3. Make a GitHub token with proper permissions for uploading releases to your repositories.

4. Create local_manifests repo in github and upload your manifest.

# How To Use This Script

1. Clone your fork of this repository.

2. Make your changes in `config.sh`.

3. run `first_time.sh` even if you already built Android on your PC before.

4. run `start.sh` to start the script.

# How to create local_manifests
Use this example as a guide

        <?xml version="1.0" encoding="UTF-8"?>
        <manifest>
            <!-- remote source -->
            <remote name="LineageOS" fetch="https://github.com/LineageOS" />
            <remote name="TheMuppets" fetch="https://github.com/TheMuppets" />

            <!-- Device Tree -->
            <project name="android_device_samsung_beyond1lte"        path="device/samsung/beyond1lte"        remote="LineageOS"  revision="lineage-18.1" />
            <project name="android_device_samsung_exynos9820-common" path="device/samsung/exynos9820-common" remote="LineageOS"  revision="lineage-18.1" />
            <project name="android_device_samsung_slsi_sepolicy"     path="device/samsung_slsi/sepolicy"     remote="LineageOS"  revision="lineage-18.1"  clone-depth="1" />
            <project name="proprietary_vendor_samsung"               path="vendor/samsung"                   remote="TheMuppets" revision="lineage-18.1" clone-depth="1" />
            <project name="android_kernel_samsung_exynos9820"        path="kernel/samsung/exynos9820"        remote="LineageOS"  revision="lineage-18.1" clone-depth="1" />
        
            <!-- HALs -->
            <project name="android_hardware_samsung"                 path="hardware/samsung"                 remote="LineageOS"  revision="lineage-18.1" clone-depth="1" />
            <project name="android_hardware_samsung_nfc"             path="hardware/samsung/nfc"             remote="LineageOS"  revision="lineage-18.1" clone-depth="1" />
        </manifest> 

# Configuration flags

`ROM_NAME` - name of your ROM ( For Example `LineageOS`)

`REPO_URL` -  URL link to ROM manifest ( For Example `https://github.com/LineageOS/android`)

`REPO_BRANCH` -  name of your ROM ( For Example `lineage-18.1`)

`MANIFEST_URL` -  URL link to your manifest ( For Example `https://github.com/Orel6505/local_manifests`)

`MANIFEST_BRANCH` -  manifest branch 


`DEVICE_CODENAME` - Device codenames (For Example: `"beyond1lte"` for Samsung Galaxy S10, you can send more than 1 device (don't forget to include them in your manifest). for example: `"beyond0lte beyond1lte beyond2lte"`)

`LUNCH_NAME` - ROM's custom lunch name (For Example: `lineage` from `lineage_beyond1lte-userdebug`)

`BACON_NAME` - ROM's custom bacon name (For Example: most of the roms using `bacon`)


`UPLOAD_TYPE` -`GD` for Gdrive, `GH` for Github and `OFF` for disable upload

`BUILD_TYPE` - Describe for what purpose this build (For Example: `Test`)

`ANDROID_VERSION` - useless for now 


`GD_PATH` - Gdrive upload path - useless for now


`GH_USERNAME` - your GitHub username (for Example `Orel6505`)

`GH_REPO` - your Github releases repo (you can use any repo for releases)


`TELEGRAM_USERNAME` - your Telegram username (for Example `@Orel6505`)

`TELEGRAM_TOKEN` - your Telegram bot token (for Example `123456:AbcDefGhi-JklMnoPrw`)

`TELEGRAM_CHAT` - your Telegram group id (add `@missrose_bot` to your group and send `/id` to see your group id)



