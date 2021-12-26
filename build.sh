#!/bin/bash

#
# Orel6505
#

## Sync

###
SF_USER="<your username here>"
SF_PROJECT="<project _name here>"
export SF_PASS=<sourceforge password needs to be passed in this variable u can do it in your way>

###
sync() {
    if ! [ -d "${MY_DIR}"/rom/"${ROM_NAME}"-"${REPO_BRANCH}" ]; then
        mkdir "${MY_DIR}"/rom/"${ROM_NAME}"-"${REPO_BRANCH}"
    fi
    cd "${MY_DIR}"/rom/"${ROM_NAME}"-"${REPO_BRANCH}"
    START_REPO=$(date +"%s")
    repo init -u "${REPO_URL}" -b "${REPO_BRANCH}" --depth=1
    if [ -d ".repo/local_manifests" ]; then
        rm -fr ".repo/local_manifests"
    fi
    git clone "${MANIFEST_URL}" -b "${MANIFEST_BRANCH}" .repo/local_manifests

    curl -s --data parse_mode=HTML --data text="Startd to sync ${ROM_NAME}!" --data chat_id="${TELEGRAM_CHAT}" --request POST https://api.telegram.org/bot"${TELEGRAM_TOKEN}"/sendMessage 

    repo sync --force-sync --no-tags --no-clone-bundle
    if ! [ -d "${MY_DIR}"/rom/"${ROM_NAME}"-"${REPO_BRANCH}/bootable" ]; then 
        END_REPO=$(date +"%s")
        DIFF_REPO=$((END_REPO-START_REPO))

        curl -s --data parse_mode=HTML --data text="${ROM_NAME} Sync failed in $((DIFF_REPO / 3600)) hours, $((DIFF_REPO % 3600 / 60)) minutes and $((DIFF_REPO % 60)) seconds!
"${TELEGRAM_USERNAME}" don't be lazy and open build machine for errors" --data chat_id="${TELEGRAM_CHAT}" --request POST https://api.telegram.org/bot"${TELEGRAM_TOKEN}"/sendMessage 
        
        curl -s --data parse_mode=HTML --data chat_id=$TELEGRAM_CHAT --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --data chat_id="${TELEGRAM_CHAT}" --request POST https://api.telegram.org/bot"${TELEGRAM_TOKEN}"/sendSticker
        exit 1
    else
        END_REPO=$(date +"%s")
        DIFF_REPO=$((END_REPO-START_REPO))

        curl -s --data parse_mode=HTML --data text="${ROM_NAME} source synced successfully! It's took ((DIFF_REPO / 3600)) hours, $((DIFF_REPO % 3600)) minutes and $((DIFF_REPO % 60)) seconds!" --data chat_id="${TELEGRAM_CHAT}" --request POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage 
        curl -s --data parse_mode=HTML --data text="The sync succedded, Starting to build..." --data chat_id=$TELEGRAM_CHAT --data chat_id="${TELEGRAM_CHAT}" --request POST https://api.telegram.org/bot"${TELEGRAM_TOKEN}"/sendMessage 

    fi
}

## Build 
build() {
    cd "${MY_DIR}"/rom/"${ROM_NAME}"-"${REPO_BRANCH}"
    #repo sync --force-sync --no-tags --no-clone-bundle
    source build/envsetup.sh
    for CODENAME in ${DEVICE_CODENAME}
    do
        lunch "${LUNCH_NAME}"_"${CODENAME}"-userdebug
        START_BUILD=$(date +"%s")
        if [ -e "{${OUT_DIR}"/out/target/product/"${CODENAME}"/build_fingerprint.txt ]; then
	        END_BUILD=$(date +"%s")
	        DIFF_BUILD=$((END_BUILD-START_BUILD))

	        telegram -M "dumpvars for ${CODENAME} failed.
"${TELEGRAM_USERNAME}" don't be lazy and open build machine for errors"
            
            curl -s --data parse_mode=HTML --data chat_id="${TELEGRAM_CHAT}" --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot"${TELEGRAM_TOKEN}"/sendSticker
            exit 1
        fi
        curl -s --data parse_mode=HTML --data text="${ROM_NAME}-${REPO_BRANCH} Build for ${CODENAME} started!" --data chat_id="${TELEGRAM_CHAT}" --request POST https://api.telegram.org/bot"${TELEGRAM_TOKEN}"/sendMessage 
        make ${BACON_NAME}
        BUILD_STATUS=${?}
        if [ "${BUILD_STATUS}" != 0 ]; then
	        END_BUILD=$(date +"%s")
	        DIFF_BUILD=$((END_BUILD-START_BUILD))

	        curl -s --data parse_mode=HTML --data text="Build for ${CODENAME} failed in $((DIFF_BUILD / 3600)) hours, $((DIFF_BUILD % 3600 / 60)) minutes and $((DIFF_BUILD % 60)) seconds!
"${TELEGRAM_USERNAME}" don't be lazy and open build machine for errors" --data chat_id="${TELEGRAM_CHAT}" --request POST https://api.telegram.org/bot"${TELEGRAM_TOKEN}"/sendMessage 
            curl -s --data parse_mode=HTML --data chat_id="${TELEGRAM_CHAT}" --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot"${TELEGRAM_TOKEN}"/sendSticker

            exit 1
        else
            END_BUILD=$(date +"%s")
	        DIFF_BUILD=$((END_BUILD-START_BUILD))

            curl -s --data parse_mode=HTML --data text="${ROM_NAME} for ${CODENAME} succeed!
The build took $((DIFF_BUILD / 3600)) hours, $((DIFF_BUILD % 3600 / 60)) minutes and $((DIFF_BUILD % 60)) seconds!" --data chat_id="${TELEGRAM_CHAT}" --request POST https://api.telegram.org/bot"${TELEGRAM_TOKEN}"/sendMessage 
            
            cd out/target/product/"${CODENAME}"
            ROM_ZIP=$(find -type f -name "*.zip" -exec stat -c '%Y %n' {} \; | sort -nr | awk 'NR==1,NR==1 {print $2 }') 
            ROM_ZIP="$(basename $ROM_ZIP)"
            ROM_HASH=ls "*.sha256sum"
            if ! [ "${ROM_HASH}" == "" ]; then
                ROM_HASH256=$(find -type f -name "*.sha256sum" -exec stat -c '%Y %n' {} \; | sort -nr | awk 'NR==1,NR==1 {print $2 }')
                ROM_HASH="$(basename $ROM_HASH256)"
            else 
                ROM_HASH5=$(find -type f -name "*.md5sum" -exec stat -c '%Y %n' {} \; | sort -nr | awk 'NR==1,NR==1 {print $2 }')
                ROM_HASH="$(basename $ROM_HASH5)"
            fi

            #if github release
            if [ "${UPLOAD_TYPE}" == "GH" ]; then
                GH_RELEASE="${BUILD_TYPE}"-"${ROM_ZIP}"
                if ! [ -d "${MY_DIR}"/"${GH_REPO}" ]; then
                    git clone https://github.com/"${GH_USERNAME}"/"${GH_REPO}" "${MY_DIR}"
                fi
                cp "${ROM_ZIP}" "${MY_DIR}"/"${GH_REPO}"
                cp "${ROM_HASH}" "${MY_DIR}"/"${GH_REPO}"
                cd "${MY_DIR}"/"${GH_REPO}"
                gh release create "${GH_RELEASE}" "${ROM_ZIP}" "${ROM_HASH}" -t "${GH_RELEASE}"
                curl -s --data parse_mode=HTML --data text="Upload ${ROM_ZIP} for ${CODENAME} succeed! The upload took $((DIFF_BUILD / 3600)) hours, $((DIFF_BUILD % 3600 / 60)) minutes and $((DIFF_BUILD % 60)) seconds!
Download! https://github.com/${GH_USERNAME}/${GH_REPO}/${GH_RELEASE})" --data "reply_markup": {"inline_keyboard": [[{"text":"Download!", "url": "https://github.com/${GH_USERNAME}/${GH_REPO}/${GH_RELEASE}"}]]} --data chat_id="${TELEGRAM_CHAT}" --request POST https://api.telegram.org/bot"${TELEGRAM_TOKEN}"/sendMessage
                curl -s --data parse_mode=HTML --data chat_id="${TELEGRAM_CHAT}" --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot"${TELEGRAM_TOKEN}"/sendSticker
            fi

            #if github release
            if [ "${UPLOAD_TYPE}" == "SF" ]; then
			 sshpass -p '${SF_PASS}' scp ${ROM_ZIP} ${SF_USER}@frs.sourceforge.net:/home/frs/project/${SF_PROJECT}/${CODENAME}/
			 ## Add your telegram message here
			 ## please 1 time to normal sftp username@frs.sourceforge.et and login once before running script , you would need install sshpass is not available
            fi

            #if google drive
            if [ "${UPLOAD_TYPE}" == "GD" ]; then
                GD_RELEASE="${BUILD_TYPE}"-"${ROM_ZIP}"
                if ! [ -d "${GDRIVE_FOLDER}" ]; then
                    mkdir "${GDRIVE_FOLDER}"
                fi
                cp "${ROM_ZIP}" "${GDRIVE_FOLDER}"
                cp "${ROM_HASH}" "${GDRIVE_FOLDER}"
                cd "${GDRIVE_FOLDER}"
                ./"${GDRIVE_FOLDER}"/gdrive upload "${ROM_ZIP}"
                curl -s --data parse_mode=HTML --data text="Upload ${ROM_ZIP} for ${CODENAME} succeed!" --data "reply_markup": {"inline_keyboard": [[{"text":"Download!", "url": "https://drive.google.com/folderview?id=1-04oC14tCH6vPsaMd5_bRnfLWI9Te6hA"}]]} --data chat_id="${TELEGRAM_CHAT}" --request POST https://api.telegram.org/bot"${TELEGRAM_TOKEN}"/sendMessage
            fi
            cd "${MY_DIR}"/rom/"${ROM_NAME}"-"${REPO_BRANCH}"
        fi
    done
}

## Start
if ! [ -d "${MY_DIR}"/rom/"${ROM_NAME}"-"${REPO_BRANCH}/bootable" ]; then
    sync
fi
build
cd "${MY_DIR}"
