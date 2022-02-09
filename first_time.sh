#!/bin/bash

#
# Copyright (C) 2022 Orel6505
#
# SPDX-License-Identifier: GNU General Public License v3.0
#

export MY_DIR=$(pwd)

## Packages
sudo apt install git repo adb fastboot curl openssh-client sshpass -y bc bison build-essential flex g++-multilib gcc-multilib gnupg gperf imagemagick lib32ncurses5-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lunzip lzop pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev openjdk-8-jdk python perl git git-lfs libncurses5 xmlstarlet virtualenv xz-utils rr jq ruby gem ccache libssl-dev hashalot

## Gdrive
echo -n "Do you want to setup Gdrive?: "
read SETUP_GD
if [ "${SETUP_GD}" = "Yes" ] || [ "${SETUP_GD}" = "yes" ] || [ "${SETUP_GD}" = "Y" ]; then
    GD_FOLDER="${MY_DIR}/gd"
    if ! [ -d "${MY_DIR}"/gd ]; then
        mkdir "${MY_DIR}"/gd
    fi
    cd gd
    wget https://github.com/prasmussen/gdrive/releases/download/2.1.1/gdrive_2.1.1_linux_386.tar.gz
    tar –xzf gdrive_2.1.1_linux_386.tar.gz
    chmod +x gdrive
    rm gdrive_2.1.1_linux_386.tar.gz
    ./gdrive about
    cd "${MY_DIR}"
fi

echo -n "Do you want to setup Github releases?: "
read SETUP_GH
if [ "${SETUP_GH}" = "Yes" ] || [ "${SETUP_GH}" = "yes" ] || [ "${SETUP_GH}" = "Y" ]; then
    wget https://github.com/cli/cli/releases/download/v2.4.0/gh_2.4.0_linux_amd64.deb
    sudo dpkg -i gh_2.4.0_linux_amd64.deb
    rm gh_2.4.0_linux_amd64.deb
    gh auth login
fi

echo -n "Do you want to setup SourceForge?: "
read SETUP_SF
if [ "${SETUP_SF}" = "Yes" ] || [ "${SETUP_SF}" = "yes" ] || [ "${SETUP_SF}" = "Y" ]; then
    echo -n "Please enter your SourceForge username: "
    read SF_USER
    echo -n "After connecting, please run exit."
    sftp "${SF_USER}"@frs.sourceforge.net
fi
