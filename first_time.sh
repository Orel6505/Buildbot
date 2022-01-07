#!/bin/bash

#
# Orel6505
#

export MY_DIR=$(pwd)

## Packages
sudo apt install git repo adb fastboot curl sshpass scp gh -y bc bison build-essential flex g++-multilib gcc-multilib gnupg gperf imagemagick lib32ncurses5-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lunzip lzop pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev openjdk-8-jdk python perl git git-lfs libncurses5 xmlstarlet virtualenv xz-utils rr jq ruby gem ccache libssl-dev 

## Gdrive
echo -n "Do you want to setup Gdrive?: "
read SETUP_GD
if [ "${SETUP_GD}" = "Yes" ] || [ "${SETUP_GD}" = "yes" ] || [ "${SETUP_GD}" = "Y" ]; then
    GD_FOLDER="${MY_DIR}/gd"
    if ! [ -d "${MY_DIR}"/gd ]; then
        mkdir "${MY_DIR}"/gd
    fi
    wget -P "${GD_FOLDER}" https://github.com/prasmussen/gdrive/releases/download/2.1.1/gdrive_2.1.1_linux_386.tar.gz
    tar -xf "${GD_FOLDER}"/gdrive_2.1.1_linux_386.tar.gz -C "${GD_FOLDER}"
    chmod +x "${GD_FOLDER}"/gdrive
    rm -fr "${GD_FOLDER}"/gdrive_2.1.1_linux_386.tar.gz
    cd gd
    ./gdrive about
fi

echo -n "Do you want to setup Github releases?: "
read SETUP_GH
if [ "${SETUP_GH}" = "Yes" ] || [ "${SETUP_GH}" = "yes" ] || [ "${SETUP_GH}" = "Y" ]; then
    gh auth login
fi
