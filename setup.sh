#!/bin/bash

#
# Copyright (C) 2022 Orel6505
#
# SPDX-License-Identifier: GNU General Public License v3.0
#

export MY_DIR=$(pwd)

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

## Packages
cat /etc/os-release > .KNOX
OS_NAME=$(awk '/ID=/' .KNOX | sed '/VERSION_ID/d' | cut -f2 -d '=')
OS_NAME2=$(awk '/NAME=/' .KNOX | sed '/PRETTY/d' | sed '/CODENAME/d' | cut -f2 -d '=')
OS_DISTRO=$(awk '/ID_LIKE=/' .KNOX | cut -f2 -d '=')
if [[ "${OS_NAME}" == *"ubuntu"* ]] || [[ "${OS_NAME2}" == *"ubuntu"* ]]; then
    UBUNTU_VERSION=$(awk '/VERSION_ID=/' .KNOX | cut -f2 -d '=')
    if [[ "${UBUNTU_VERSION}" == *"21.04"* ]] || [[ "${UBUNTU_VERSION}" == *"21.10"* ]]; then
        sudo apt install git repo adb fastboot curl openssh-client sshpass -y bc bison build-essential flex g++-multilib gcc-multilib gnupg gperf imagemagick lib32ncurses5-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lunzip lzop pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev openjdk-8-jdk python perl git git-lfs libncurses5 xmlstarlet virtualenv xz-utils rr jq ruby gem ccache libssl-dev ucommon-utils
    elif [[ "${UBUNTU_VERSION}" == *"20.04"* ]]; then
        sudo apt-get install openssh-client sshpass coreutils ucommon-utils git ccache lzop bison build-essential zip curl zlib1g-dev g++-multilib libxml2-utils bzip2 libbz2-dev libghc-bzlib-dev squashfs-tools pngcrush liblz4-tool optipng libc6-dev-i386 gcc-multilib libssl-dev gnupg flex lib32ncurses-dev x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev xsltproc unzip libffi-dev libxml2-dev libxslt1-dev libjpeg8-dev fontconfig libncurses5-dev libncurses5 libncurses5:i386 python-is-python3
        mkdir ~/bin 
        curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
        chmod a+x ~/bin/repo
    fi
fi

if [[ "${OS_NAME}" == *"Arch"* ]] || [[ "${OS_NAME2}" == *"Arch"* ]]; then
    sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
    sudo pacman -Syyu --noconfirm --needed multilib-devel
    pacman -S coreutils sshpass
    DEFAULT_USER=$(who | cut -f1 -d " ")
    for PACKAGE in "aosp-devel lineageos-devel xml2 ffmpeg imagemagick lzop ninja gradle maven"; do
        git clone https://aur.archlinux.org/"${PACKAGE}"
        cd "${PACKAGE}"
        su "${DEFAULT_USER}" -c "makepkg -si --skippgpcheck --noconfirm --needed"
        cd ..
        rm -rf "${PACKAGE}"
    done
    mkdir ~/bin
    curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo 
    chmod a+x ~/bin/repo
fi

if [[ "${OS_NAME}" == *"Fedora"* ]] || [[ "${OS_NAME2}" == *"Fedora"* ]]; then
    sudo dnf update -y
    sudo dnf install -y \
        @development-tools \
        android-tools \
        automake \
        bc \
        bison \
        bzip2 \
        bzip2-libs \
        ccache \
        curl \
        dpkg-dev \
        gcc-c++ \
        git \
        gperf \
        hostname \
        ImageMagick-devel.x86_64 \
        ImageMagick-c++-devel.x86_64 \
        java-1.8.0-openjdk \
        libstdc++.i686 \
        libxml2-devel \
        lz4-libs \
        lzop \
        make \
        maven \
        ncurses-compat-libs \
        optipng \
        pngcrush \
        python \
        python3 \
        python3-mako \
        python-mako \
        python-networkx \
        rsync \
        sshpass \
        schedtool \
        squashfs-tools \
        syslinux-devel \
        zip \
        zlib-devel \
        zlib-devel.i686 
    mkdir ~/bin
    curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    chmod a+x ~/bin/repo
fi
rm .KNOX

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

# Github releases
echo -n "Do you want to setup Github releases?: "
read SETUP_GH
if [ "${SETUP_GH}" = "Yes" ] || [ "${SETUP_GH}" = "yes" ] || [ "${SETUP_GH}" = "Y" ]; then
    if [[ "${OS_NAME}" == *"Ubuntu"* ]] || [[ "${OS_NAME2}" == *"Ubuntu"* ]]; then
        wget https://github.com/cli/cli/releases/download/v2.5.2/gh_2.5.2_linux_amd64.deb
        sudo dpkg -i gh_2.5.2_linux_amd64.deb
        rm gh_2.5.2_linux_amd64.deb
        gh auth login
    elif [[ "${OS_NAME}" == *"Fedora"* ]] || [[ "${OS_NAME2}" == *"Fedora"* ]]; then
        sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
        sudo dnf install gh
    elif [[ "${OS_NAME}" == *"Arch"* ]] || [[ "${OS_NAME2}" == *"Arch"* ]]; then
        git clone https://aur.archlinux.org/github-cli-git
        cd github-cli-git
        makepkg -si --skippgpcheck --noconfirm --needed
        cd ..
        rm -rf github-cli-git
    fi
fi

# Sourceforge
echo -n "Do you want to setup SourceForge?: "
read SETUP_SF
if [ "${SETUP_SF}" = "Yes" ] || [ "${SETUP_SF}" = "yes" ] || [ "${SETUP_SF}" = "Y" ]; then
    echo -n "Please enter your SourceForge username: "
    read SF_USER
    echo -n "After connecting, please run exit."
    sftp "${SF_USER}"@frs.sourceforge.net
fi