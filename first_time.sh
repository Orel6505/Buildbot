#!/bin/bash

#
# Orel6505
#

export MY_DIR=$(pwd)
GDRIVE_FOLDER="${MY_DIR}/gdrive"
if ! [ -d "${MY_DIR}"/gdrive ]; then
    mkdir "${MY_DIR}"/gdrive
fi

## Packages
sudo apt install git repo adb fastboot curl gh -y bc bison build-essential flex g++-multilib gcc-multilib gnupg gperf imagemagick lib32ncurses5-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lunzip lzop pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev openjdk-8-jdk python perl git git-lfs libncurses5 xmlstarlet virtualenv xz-utils rr jq ruby gem ccache libssl-dev 

## Gdrive
wget -P "${GDRIVE_FOLDER}" https://github.com/prasmussen/gdrive/releases/download/2.1.1/gdrive_2.1.1_linux_386.tar.gz
tar -xf "${GDRIVE_FOLDER}"/gdrive_2.1.1_linux_386.tar.gz -C "${BIN_FOLDER}"
chmod +x "${GDRIVE_FOLDER}"/gdrive
rm -fr "${GDRIVE_FOLDER}"/gdrive_2.1.1_linux_386.tar.gz

cd gdrive
./gdrive/gdrive about

gh auth login