#!/bin/bash

#
# Copyright (C) 2022 Orel6505
#
# SPDX-License-Identifier: GNU General Public License v3.0
#

MY_DIR=$(pwd)
echo -e "---------beginning of log" > "${MY_DIR}"/buildbot_log.txt

## Check if the config is valid
CONFIG_KNOX=0
if [ "${ROM_NAME}" = "" ] && [ "${ANDROID_VERSION}" = "" ] && [ "${REPO_URL}" = "" ] && [ "${REPO_BRANCH}" = "" ] && [ "${DEVICE_CODENAME}" = "" ] && [ "${LUNCH_NAME}" = "" ] && [ "${BACON_NAME}" = "" ]; then
    echo -e "$(date +"%Y-%m-%d") $(date +"%T") F: please run config.sh instead of running build.sh, exiting..." >> "${MY_DIR}"/buildbot_log.txt
    return 1
fi

if [ "${ROM_NAME}" = "" ] || [ "${ANDROID_VERSION}" = "" ] || [ "${REPO_URL}" = "" ] || [ "${REPO_BRANCH}" = "" ] || [ "${DEVICE_CODENAME}" = "" ] || [ "${LUNCH_NAME}" = "" ] || [ "${BACON_NAME}" = "" ]; then
    if [ "${ROM_NAME}" = "" ]; then
        echo -e "$(date +"%Y-%m-%d") $(date +"%T") E: ROM_NAME is requierd in config" >> "${MY_DIR}"/buildbot_log.txt
        CONFIG_KNOX="$((${CONFIG_KNOX} + 1))"
    fi
    if [ "${ANDROID_VERSION}" = "" ]; then
        echo -e "$(date +"%Y-%m-%d") $(date +"%T") E: ANDROID_VERSION is requierd in config" >> "${MY_DIR}"/buildbot_log.txt
        CONFIG_KNOX="$((${CONFIG_KNOX} + 1))"
    fi
    if [ "${REPO_URL}" = "" ]; then
        echo -e "$(date +"%Y-%m-%d") $(date +"%T") E: REPO_URL is requierd in config" >> "${MY_DIR}"/buildbot_log.txt
        CONFIG_KNOX="$((${CONFIG_KNOX} + 1))"
    fi
    if [ "${REPO_BRANCH}" = "" ]; then
        echo -e "$(date +"%Y-%m-%d") $(date +"%T") E: REPO_BRANCH is requierd in config" >> "${MY_DIR}"/buildbot_log.txt
        CONFIG_KNOX="$((${CONFIG_KNOX} + 1))"
    fi
    if [ "${DEVICE_CODENAME}" = "" ]; then
        echo -e "$(date +"%Y-%m-%d") $(date +"%T") E: DEVICE_CODENAME is requierd in config" >> "${MY_DIR}"/buildbot_log.txt
        CONFIG_KNOX="$((${CONFIG_KNOX} + 1))"
    fi
    if [ "${LUNCH_NAME}" = "" ]; then
        echo -e "$(date +"%Y-%m-%d") $(date +"%T") E: LUNCH_NAME is requierd in config" >> "${MY_DIR}"/buildbot_log.txt
        CONFIG_KNOX="$((${CONFIG_KNOX} + 1))"
    fi
    if [ "${BACON_NAME}" = "" ]; then
        echo -e "$(date +"%Y-%m-%d") $(date +"%T") E: BACON_NAME is requierd in config" >> "${MY_DIR}"/buildbot_log.txt
        CONFIG_KNOX="$((${CONFIG_KNOX} + 1))"
    fi
fi

if [ "${UPLOAD_TYPE}" = "GD" ] && [ "${GD_PATH}" = "" ]; then
    echo -e "$(date +"%Y-%m-%d") $(date +"%T") W: GD_PATH is not set, uploading to generic location" >> "${MY_DIR}"/buildbot_log.txt
fi
if [ "${UPLOAD_TYPE}" = "GH" ] && [ "${GH_REPO}" = "" ]; then
    echo -e "$(date +"%Y-%m-%d") $(date +"%T") W: GH_REPO is not set, the script will no able to upload builds" >> "${MY_DIR}"/buildbot_log.txt
    UPLOAD_TYPE="OFF"
fi
if [ "${UPLOAD_TYPE}" = "GH" ] && [ "${GH_USERNAME}" = "" ]; then
    echo -e "$(date +"%Y-%m-%d") $(date +"%T") W: GH_USERNAME is not set, the script will no able to upload builds" >> "${MY_DIR}"/buildbot_log.txt
    UPLOAD_TYPE="OFF"
fi
if [ "${UPLOAD_TYPE}" = "SF" ] && [ "${SF_USER}" = "" ]; then
    echo -e "$(date +"%Y-%m-%d") $(date +"%T") W: SF_USER is not set, the script will no able to upload builds" >> "${MY_DIR}"/buildbot_log.txt
    UPLOAD_TYPE="OFF"
fi
if [ "${UPLOAD_TYPE}" = "SF" ] && [ "${SF_PASS}" = "" ]; then
    echo -e "$(date +"%Y-%m-%d") $(date +"%T") W: SF_PASS is not set, the script will no able to upload builds" >> "${MY_DIR}"/buildbot_log.txt
    UPLOAD_TYPE="OFF"
fi
if [ "${UPLOAD_TYPE}" = "SF" ] && [ "${SF_PROJECT}" = "" ]; then
    echo -e "$(date +"%Y-%m-%d") $(date +"%T") W: SF_PROJECT is not set, the script will no able to upload builds" >> "${MY_DIR}"/buildbot_log.txt
    UPLOAD_TYPE="OFF"
fi

## Sync
sync() {
    if ! [ -d "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}" ]; then
        mkdir "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}"
        echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: rom/${ROM_NAME}-${ANDROID_VERSION} directory created " >> "${MY_DIR}"/buildbot_log.txt
    fi
    cd "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}"
    START_REPO=$(date +"%s")
    repo init -u "${REPO_URL}" -b "${REPO_BRANCH}" --depth=1
    REPO_INIT_STATUS=${?}
    if [ "${REPO_INIT_STATUS}" != "0" ]; then
        echo -e "$(date +"%Y-%m-%d") $(date +"%T") E: REPO_URL link is broken, repo manifest not cloned. exiting..." >> "${MY_DIR}"/buildbot_log.txt
        return 1
    else
        if [ "${MANIFEST_URL}" != "" ]; then
            if [ -d ".repo/local_manifests" ]; then
                rm -fr ".repo/local_manifests"
            fi
            git clone "${MANIFEST_URL}" -b "${MANIFEST_BRANCH}" .repo/local_manifests --depth=1
            MANIFEST_STATUS=${?}
            if [ "${MANIFEST_STATUS}" != "0" ]; then
                echo -e "$(date +"%Y-%m-%d") $(date +"%T") W: MANIFEST_URL link is broken, manifest not cloned..." >> buildbot_log.txt
            fi
        else
            echo -e "$(date +"%Y-%m-%d") $(date +"%T") W: you started to sync ${ROM_NAME}-${ANDROID_VERSION} without device tree manifest, which can the build machine may not able to start the build later" >> buildbot_log.txt
        fi
        echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: started to sync ${ROM_NAME}-${ANDROID_VERSION}!" >> buildbot_log.txt
        if [ "${TG_CHAT}" != "" ]; then
            curl -s --data parse_mode=HTML --data text="Started to sync ${ROM_NAME}-${ANDROID_VERSION}!" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
        fi
        repo sync --force-sync --no-tags --no-clone-bundle 2<&1 | tee sync.log
        REPO_SYNC_STATUS=${?}
        if ! [ -d "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}/bootable" ] && [ ${REPO_SYNC_STATUS} != 0 ]; then 
            END_REPO=$(date +"%s")
            DIFF_REPO=$((END_REPO-START_REPO))
            if [ "${TG_CHAT}" != "" ]; then
                curl -F chat_id="${TG_CHAT}" -F document=@sync.log -F caption="${ROM_NAME}-${ANDROID_VERSION} Sync failed in $((DIFF_REPO / 3600)) hours, $((DIFF_REPO % 3600 / 60)) minutes and $((DIFF_REPO % 60)) seconds!" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendDocument 2>&1 >/dev/null
            fi
            echo -e "$(date +"%Y-%m-%d") $(date +"%T") E: Sync ${ROM_NAME}-${ANDROID_VERSION} done unsuccessfully, exiting..." >> "${MY_DIR}"/buildbot_log.txt
            return 1
        else
            END_REPO=$(date +"%s")
            DIFF_REPO=$((END_REPO-START_REPO))
            echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: Sync ${ROM_NAME}-${ANDROID_VERSION} done successfully, starting to build..." >> "${MY_DIR}"/buildbot_log.txt
            if [ "${TG_CHAT}" != "" ]; then
                curl -s --data parse_mode=HTML --data text="${ROM_NAME}-${ANDROID_VERSION} source synced successfully! It's took $((DIFF_REPO / 3600)) hours, $((DIFF_REPO % 3600 / 60)) minutes and $((DIFF_REPO % 60)) seconds!" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot$TG_TOKEN/sendMessage 2>&1 >/dev/null
                curl -s --data parse_mode=HTML --data text="The sync succedded, Starting to build..." --data chat_id=$TG_CHAT --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
            fi
        fi
    fi
}

## Build 
build() {
    cd "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}"
    repo sync --force-sync --no-tags --no-clone-bundle
    source build/envsetup.sh
    for CODENAME in ${DEVICE_CODENAME}
    do
        if [ "${AUTO_BRINGUP}" == "Y" ] || [ "${AUTO_BRINGUP}" == "yes" ] || [ "${AUTO_BRINGUP}" == "Yes" ]; then
            echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: started to bringup device tree for ${CODENAME}!" >> "${MY_DIR}"/buildbot_log.txt
            VENDOR_NAME="$(find . ~ -type d -name "${CODENAME}" | sort -nr | awk 'NR==1,NR==1')"
            VENDOR_NAME="$(dirname $VENDOR_NAME)"
            VENDOR_NAME="$(basename $VENDOR_NAME)"
            cd "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}"/device/"${VENDOR_NAME}"/"${CODENAME}"
            PREBUILT_LUNCH=$(ls *${CODENAME}*|cut -f1 -d _)
            sed -i "s/${PREBUILT_LUNCH}/${LUNCH_NAME}/g" ${PREBUILT_LUNCH}_${CODENAME}.mk
            if [ -e "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}"/vendor/"${LUNCH_NAME}"/config/common_full_phone.mk ]; then
                sed -i "/call inherit-product, vendor/c\$(call inherit-product, vendor/${LUNCH_NAME}/config/common_full_phone.mk)" ${PREBUILT_LUNCH}_${CODENAME}.mk
            else
                sed -i "/call inherit-product, vendor/c\$(call inherit-product, vendor/${LUNCH_NAME}/config/common.mk)" ${PREBUILT_LUNCH}_${CODENAME}.mk
            fi
            sed -i "s/${PREBUILT_LUNCH}/${LUNCH_NAME}/g" AndroidProducts.mk
            mv ${PREBUILT_LUNCH}_${CODENAME}.mk ${LUNCH_NAME}_${CODENAME}.mk
            cd "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}"
        fi
        echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: lunch for ${CODENAME} started!"  >> "${MY_DIR}"/buildbot_log.txt
        lunch "${LUNCH_NAME}"_"${CODENAME}"-userdebug > lunch.log
        START_BUILD=$(date +"%s")
        if grep -q "error" lunch.log; then
	        END_BUILD=$(date +"%s")
	        DIFF_BUILD=$((END_BUILD-START_BUILD))
            if [ "${TG_CHAT}" != "" ]; then
                curl -F document=@lunch.log -F caption="lunch for ${CODENAME} failed." --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendDocument?chat_id="${TG_CHAT}" 2>&1 >/dev/null
            fi
            if [ "${AUTO_BRINGUP}" == "Y" ] || [ "${AUTO_BRINGUP}" == "yes" ] || [ "${AUTO_BRINGUP}" == "Yes" ]; then
                echo -e "$(date +"%Y-%m-%d") $(date +"%T") E: bringup device tree for ${CODENAME} failed!" >> "${MY_DIR}"/buildbot_log.txt
                echo -e "$(date +"%Y-%m-%d") $(date +"%T") F: lunch for ${CODENAME} failed." >> "${MY_DIR}"/buildbot_log.txt
                echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: Please dm @Orel6505 and send him terminal log and tell him to fix auto bringup" >> "${MY_DIR}"/buildbot_log.txt
            else
                echo -e "$(date +"%Y-%m-%d") $(date +"%T") F: lunch for ${CODENAME} failed." >> "${MY_DIR}"/buildbot_log.txt
            fi
            break 1
        else
            sed -i "/Trying dependencies-only mode on a/c\ " lunch.log
            sed -i '/^\s*$/d' lunch.log
            if [ "${TG_CHAT}" != "" ]; then
                curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
<code>$(cat lunch.log)</code>" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
            fi
            echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: build for ${CODENAME} started!"  >> "${MY_DIR}"/buildbot_log.txt
            make ${BACON_NAME}
            BUILD_STATUS=${?}
            if [ "${BUILD_STATUS}" != 0 ]; then
	            END_BUILD=$(date +"%s")
	            DIFF_BUILD=$((END_BUILD-START_BUILD))
                if [ "${TG_CHAT}" != "" ]; then
                    curl -F chat_id="${TG_CHAT}" -F document=@out/error.log -F caption="The ${ROM_NAME}-${ANDROID_VERSION} build for ${CODENAME} failed in $((DIFF_BUILD / 3600)) hours, $((DIFF_BUILD % 3600 / 60)) minutes and $((DIFF_BUILD % 60)) seconds!" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendDocument 2>&1 >/dev/null
                fi
                echo -e "$(date +"%Y-%m-%d") $(date +"%T") E: build for ${CODENAME} failed."  >> "${MY_DIR}"/buildbot_log.txt
                break 1
            else
                END_BUILD=$(date +"%s")
	            DIFF_BUILD=$((END_BUILD-START_BUILD))
                echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: build for ${CODENAME} done successfully!"  >> "${MY_DIR}"/buildbot_log.txt
                if [ "${TG_CHAT}" != "" ]; then
                    curl -s --data parse_mode=HTML --data text="The ${ROM_NAME}-${ANDROID_VERSION} build for ${CODENAME} succeed!
The build took $((DIFF_BUILD / 3600)) hours, $((DIFF_BUILD % 3600 / 60)) minutes and $((DIFF_BUILD % 60)) seconds!" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                fi
                cd "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}"/out/target/product/"${CODENAME}"
                ROM_ZIP=$(find -type f -name "*${CODENAME}*.zip" -exec stat -c '%Y %n' {} \; | sort -nr | head -n 20 | awk 'NR==1,NR==1 {print $2}')
                ROM_ZIP=$(basename "${ROM_ZIP}")
                ROM_ZIP_KNOX="0x1"
                while [ "${ROM_ZIP_KNOX}" == "0x1" ]; do
                    KNOX_TMP1= $(grep -q "eng" "${ROM_ZIP}")
                    if [ "${KNOX_TMP1}" == "" ]; then
                        ROM_ZIP_KNOX="0x0"
                    else
                        ROM_ZIP=$(find -type f -name "*${CODENAME}*.zip" -exec stat -c '%Y %n' {} \; | sort -nr | head -n 20 | awk 'NR==2,NR==2 {print $2}')
                    fi
                done
                ROM_SIZE=$(ls -lh "${ROM_ZIP}" | cut -f5 -d " ")
                ROM_HASH=$(sha256sum "${ROM_ZIP}" | cut -f1 -d " ")
                if [ -e recovery.img ] && [ "${UPLOAD_RECOVERY}" = "true" ]; then
                    RECOVERY_IMG="recovery.img"
                fi

                #if github release
                if [ "${UPLOAD_TYPE}" == "GH" ]; then
                    GH_RELEASE="${BUILD_TYPE}"-"${ROM_ZIP}"
                    if ! [ -d "${MY_DIR}"/"${GH_REPO}" ]; then
                        git clone https://github.com/"${GH_USERNAME}"/"${GH_REPO}" "${MY_DIR}"
                    fi
                    cp "${ROM_ZIP}" "${MY_DIR}"/"${GH_REPO}"
                    cp "${ROM_HASH}" "${MY_DIR}"/"${GH_REPO}"
                    if [ "${UPLOAD_RECOVERY}" = "true" ]; then
                        cp "${RECOVERY_IMG}" "${MY_DIR}"/"${GH_REPO}"
                    fi
                    cd "${MY_DIR}"/"${GH_REPO}"
                    if [ "${UPLOAD_RECOVERY}" = "true" ]; then
                        echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: starting to upload to github"  >> "${MY_DIR}"/buildbot_log.txt
                        gh release create "${GH_RELEASE}" -t "${GH_RELEASE}" "${ROM_ZIP}" "${RECOVERY_IMG}"
                        rm "${RECOVERY_IMG}"
                    else
                        echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: starting to upload to github"  >> "${MY_DIR}"/buildbot_log.txt
                        gh release create "${GH_RELEASE}" -t "${GH_RELEASE}" "${ROM_ZIP}"
                    fi
                    if [ "${TG_CHAT}" != "" ]; then
                        curl -s --data parse_mode=HTML --data text="Upload ${ROM_ZIP} for ${CODENAME} succeed!" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                        curl -s --data parse_mode=HTML --data text="📱 <b>New build available for ${CODENAME}</b>
👤 by ${TG_USER}

ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
📅 Build date: <code>$(date +"%d-%m-%Y")</code>
📎 File size: <code>${ROM_SIZE}</code>
✅ SHA256: <code>${HASH_ZIP}</code>" --data reply_markup="{\"inline_keyboard\": [[{\"text\":\"Download!\", \"url\": \"https://github.com/${GH_USERNAME}/${GH_REPO}/${GH_RELEASE}\"}]]}" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                    fi
                    echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: Upload ${ROM_ZIP} for ${CODENAME} done successfully!"  >> "${MY_DIR}"/buildbot_log.txt 
                fi

                #if sourceforge release
                if [ "${UPLOAD_TYPE}" == "SF" ]; then
                    if [ "${SF_PATH}" == "" ]; then
                        echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: starting to upload to SourceForge"  >> "${MY_DIR}"/buildbot_log.txt
			            sshpass -p "${SF_PASS}" scp ${ROM_ZIP} ${SF_USER}@frs.sourceforge.net:/home/frs/project/${SF_PROJECT}/${CODENAME}
                        if [ "${UPLOAD_RECOVERY}" = "true" ]; then
                            sshpass -p "${SF_PASS}" scp ${RECOVERY_IMG} ${SF_USER}@frs.sourceforge.net:/home/frs/project/${SF_PROJECT}/${CODENAME}
                        fi
                        if [ "${TG_CHAT}" != "" ]; then
			                curl -s --data parse_mode=HTML --data text="Upload ${ROM_ZIP} for ${CODENAME} succeed!" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                            curl -s --data parse_mode=HTML --data text="📱 <b>New build available for ${CODENAME}</b>
👤 by ${TG_USER}

ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
📅 Build date: <code>$(date +"%d-%m-%Y")</code>
📎 File size: <code>${ROM_SIZE}</code>
✅ SHA256: <code>${HASH_ZIP}</code>" --data reply_markup="{\"inline_keyboard\": [[{\"text\":\"Download!\", \"url\": \"https://sourceforge.net/projects/${SF_PROJECT}/files/${CODENAME}/\"}]]}" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                        fi
                        echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: upload to SourceForge done successfully"  >> "${MY_DIR}"/buildbot_log.txt
                    else
                        echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: starting to upload to SourceForge"  >> "${MY_DIR}"/buildbot_log.txt
                        sshpass -p "${SF_PASS}" scp "${ROM_ZIP}" "${SF_USER}"@frs.sourceforge.net:/home/frs/project/"${SF_PROJECT}"/"${SF_PATH}"
                        if [ "${UPLOAD_RECOVERY}" = "true" ]; then
                            sshpass -p "${SF_PASS}" scp "${RECOVERY_IMG}" "${SF_USER}"@frs.sourceforge.net:/home/frs/project/"${SF_PROJECT}"/"${SF_PATH}"
                        fi
                        echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: upload to SourceForge done successfully"  >> "${MY_DIR}"/buildbot_log.txt
                        if [ "${TG_CHAT}" != "" ]; then
			                curl -s --data parse_mode=HTML --data text="Upload ${ROM_ZIP} for ${CODENAME} succeed!" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                            curl -s --data parse_mode=HTML --data text="📱 <b>New build available for ${CODENAME}</b>
👤 by ${TG_USER}

ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
📅 Build date: <code>$(date +"%d-%m-%Y")</code>
📎 File size: <code>${ROM_SIZE}</code>
✅ SHA256: <code>${HASH_ZIP}</code>" --data reply_markup="{\"inline_keyboard\": [[{\"text\":\"Download!\", \"url\": \"https://sourceforge.net/projects/${SF_PROJECT}/files/${SF_PATH}/\"}]]}" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                        fi
                    fi
                fi

                #if google drive
                if [ "${UPLOAD_TYPE}" == "GD" ]; then
                    GD_FOLDER="${MY_DIR}"/gd
                    if ! [ -e "${GD_FOLDER}"/gdrive ]; then
                        echo "you didn't lisen to me, Please read README.md and run first_time.sh to set Gdrive"
                    fi
                    cp "${ROM_ZIP}" "${GD_FOLDER}"
                    if [ "${UPLOAD_RECOVERY}" = "true" ]; then
                        cp "${RECOVERY_IMG}" "${GDRIVE_FOLDER}"
                    fi
                    cd "${GD_FOLDER}"
                    echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: starting to upload to Gdrive"  >> "${MY_DIR}"/buildbot_log.txt
                    ./gdrive upload "${ROM_ZIP}" --parent "${GD_PATH}" --share --delete
                    if [ "${UPLOAD_RECOVERY}" = "true" ]; then
                        ./gdrive upload "${RECOVERY_IMG}" --parent "${GD_PATH}" --share --delete
                    fi
                    echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: upload to Gdrive done successfully"  >> "${MY_DIR}"/buildbot_log.txt
                    if [ "${TG_CHAT}" != "" ]; then
                        curl -s --data parse_mode=HTML --data text="Upload ${ROM_ZIP} for ${CODENAME} succeed!" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                        curl -s --data parse_mode=HTML --data text="📱 <b>New build available for ${CODENAME}</b>
👤 by ${TG_USER}

ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
📅 Build date: <code>$(date +"%d-%m-%Y")</code>
📎 File size: <code>${ROM_SIZE}</code>
✅ SHA256: <code>${HASH_ZIP}</code>" --data reply_markup="{\"inline_keyboard\": [[{\"text\":\"Download!\", \"url\": \"https://drive.google.com/drive/folders/${GD_PATH}\"}]]}" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                    fi
                fi
                cd "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}"
            fi
        fi
    done
}

## KNOX config check
if [ "${CONFIG_KNOX}" != "0" ]; then
    echo -e "$(date +"%Y-%m-%d") $(date +"%T") F: exiting from ${CONFIG_KNOX} previous errors" >> "${MY_DIR}"/buildbot_log.txt
    return 1
fi

## Directory
if ! [ -d "${MY_DIR}"/rom ]; then
    mkdir "${MY_DIR}"/rom
fi

## Start
if ! [ -d "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}/bootable" ]; then
    sync
fi
if [ -d "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}/bootable" ]; then
    build
fi
cd "${MY_DIR}"