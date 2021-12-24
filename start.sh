#!/bin/bash

#
# Orel6505
#

## Rom directory
export MY_DIR=$(pwd)
if ! [ -d "${MY_DIR}"/rom ]; then
    mkdir "${MY_DIR}"/rom
fi

source config.sh