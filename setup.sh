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

Setup_Ubuntu () {
    case $1 in
        *"23.04"*)
            sudo apt install git repo adb fastboot curl openssh-client sshpass -y bc bison build-essential flex g++-multilib gcc-multilib gnupg gperf imagemagick lib32ncurses5-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libxml2 libxml2-utils lunzip lzop pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev openjdk-8-jdk python3 perl git git-lfs libncurses5 xmlstarlet virtualenv xz-utils rr jq ruby gem ccache libssl-dev ucommon-utils protobuf-compiler
        ;;
        *"22.10"*)
            sudo apt install git repo adb fastboot curl openssh-client sshpass -y bc bison build-essential flex g++-multilib gcc-multilib gnupg gperf imagemagick lib32ncurses5-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lunzip lzop pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev openjdk-8-jdk python2 python3 perl git git-lfs libncurses5 xmlstarlet virtualenv xz-utils rr jq ruby gem ccache libssl-dev ucommon-utils protobuf-compiler
        ;;
        *"21.04"* | *"21.10"* | *"22.04"*)
            sudo apt install git repo adb fastboot curl openssh-client sshpass -y bc bison build-essential flex g++-multilib gcc-multilib gnupg gperf imagemagick lib32ncurses5-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lunzip lzop pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev openjdk-8-jdk python perl git git-lfs libncurses5 xmlstarlet virtualenv xz-utils rr jq ruby gem ccache libssl-dev ucommon-utils protobuf-compiler
        ;;
        *"20.04"*)
            sudo apt-get install openssh-client sshpass coreutils ucommon-utils git ccache lzop bison build-essential zip curl zlib1g-dev g++-multilib libxml2-utils bzip2 libbz2-dev libghc-bzlib-dev squashfs-tools pngcrush liblz4-tool optipng libc6-dev-i386 gcc-multilib libssl-dev gnupg flex lib32ncurses-dev x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev xsltproc unzip libffi-dev libxml2-dev libxslt1-dev libjpeg8-dev fontconfig libncurses5-dev libncurses5 libncurses5:i386 python-is-python3 protobuf-compiler
            Setup_Repo
        ;;
        *)
            sudo apt-get install openssh-client sshpass coreutils ucommon-utils git ccache lzop bison build-essential zip curl zlib1g-dev g++-multilib libxml2-utils bzip2 libbz2-dev libghc-bzlib-dev squashfs-tools pngcrush liblz4-tool optipng libc6-dev-i386 gcc-multilib libssl-dev gnupg flex lib32ncurses-dev x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev xsltproc unzip libffi-dev libxml2-dev libxslt1-dev libjpeg8-dev fontconfig libncurses5-dev libncurses5 libncurses5:i386 python-is-python3 protobuf-compiler
            Setup_Repo
        ;;
    esac
}

Setup_Debian () {
    sudo apt install git repo adb fastboot curl openssh-client sshpass -y bc bison build-essential flex g++-multilib gcc-multilib gnupg gperf imagemagick lib32ncurses5-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lunzip lzop pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev openjdk-8-jdk python perl git git-lfs libncurses5 xmlstarlet virtualenv xz-utils rr jq ruby gem ccache libssl-dev ucommon-utils protobuf-compiler
}

Setup_Arch () {
    if ! grep -q "\[multilib\]" /etc/pacman.conf ; then
        sed -i '/\[multilib\]/,/^Include/ s/^#//' /etc/pacman.conf
    fi
    pacman -Syyu --noconfirm --needed multilib-devel coreutils sshpass
    DEFAULT_USER=$(who | cut -f1 -d " ")
    for PACKAGE in "aosp-devel lineageos-devel xml2 ffmpeg imagemagick lzop ninja gradle maven protobuf"; do
        git clone https://aur.archlinux.org/"${PACKAGE}".git
        cd "${PACKAGE}"
        su "${DEFAULT_USER}" -c "makepkg -si --skippgpcheck --noconfirm --needed"
        cd ..
        rm -rf "${PACKAGE}"
    done
    Setup_Repo
}

Setup_Fedora () {
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
    Setup_Repo
    curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v21.1/protoc-21.1-linux-x86_64.zip
    sudo unzip -o protoc-21.1-linux-x86_64.zip -d /usr/local bin/protoc
    sudo unzip -o protoc-21.1-linux-x86_64.zip -d /usr/local 'include/*'
    rm -f protoc-21.1-linux-x86_64.zip
}

Setup_Repo () {
    if [ -d /bin ]
        mkdir ~/bin
    fi
    curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    chmod a+x ~/bin/repo
}

Setup_GH () {
    if [[ "${OS_NAME}" == *"Ubuntu"* ]] || [[ "${OS_NAME2}" == *"Ubuntu"* ]]; then
        sudo apt install gh
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
    gh auth login
}

Setup_SF () {
    echo -n "Please enter your SourceForge username: "
    read SF_USER
    echo -n "After connecting, please run exit."
    sftp "${SF_USER}"@frs.sourceforge.net
}


cat /etc/os-release > .KNOX
OS_NAME=$(awk '/ID=/' .KNOX | sed '/VERSION_ID/d' | cut -f2 -d '=')
OS_NAME2=$(awk '/NAME=/' .KNOX | sed '/PRETTY/d' | sed '/CODENAME/d' | cut -f2 -d '=')
OS_DISTRO=$(awk '/ID_LIKE=/' .KNOX | cut -f2 -d '=')
if [[ "${OS_NAME}" == *"ubuntu"* ]] || [[ "${OS_NAME2}" == *"ubuntu"* ]]; then
    UBUNTU_VERSION=$(awk '/VERSION_ID=/' .KNOX | cut -f2 -d '=')
    Setup_Ubuntu "$UBUNTU_VERSION"
elif [[ "${OS_NAME}" == *"Debian"* ]] || [[ "${OS_NAME2}" == *"Debian"* ]] || [[ "${OS_DISTRO}" == *"Debian"* ]]; then
    Setup_Debian
elif [[ "${OS_NAME}" == *"Arch"* ]] || [[ "${OS_NAME2}" == *"Arch"* ]]; then
    Setup_Arch
elif [[ "${OS_NAME}" == *"Fedora"* ]] || [[ "${OS_NAME2}" == *"Fedora"* ]]; then
    Setup_Fedora
else
    echo "unknown"
    exit 1
fi

echo -n "Do you want to setup Github releases?: "
read SETUP_GH
if [ "${SETUP_GH}" = "Yes" ] || [ "${SETUP_GH}" = "yes" ] || [ "${SETUP_GH}" = "Y" ] || [ "${SETUP_GH}" = "y" ]; then
    Setup_GH
fi

echo -n "Do you want to setup SourceForge?: "
read SETUP_SF
if [ "${SETUP_SF}" = "Yes" ] || [ "${SETUP_SF}" = "yes" ] || [ "${SETUP_SF}" = "Y" ] || [ "${SETUP_GH}" = "y" ]; then
    Setup_SF
fi

