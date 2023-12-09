#!/bin/bash

#
# Copyright (C) 2022 Orel6505
#
# SPDX-License-Identifier: GNU General Public License v3.0
#

MY_DIR=$(pwd)
echo -e "---------beginning of log" > "${MY_DIR}"/buildbot_log.txt
if [ "${OTA_JSON}" == "true" ]; then
    MAINTAINERS_A=$(echo $MAINTAINERS | sed 's/ /,/g' | sed 's/&/ /g' | sed 's/,//g')
    MAINTAINER_COUNT=0
    for MAINTAINER in $MAINTAINERS_A
    do
        MAINTAINER_COUNT=$(expr "${MAINTAINER_COUNT}" + 1)
    done
fi
if [ "${OTA_JSON}" == "true" ] || [ "${UPLOAD_TYPE}" == "GH" ]; then
    GH_NAME=$(echo "${GH_REPO_URL}" | cut -f4 -d "/")
    GH_REPO=$(echo "${GH_REPO_URL}" | cut -f5 -d "/")
    GH_PUSH_URL="https://"${GH_USER}":"${GH_TOKEN}"@github.com/${GH_NAME}/${GH_REPO}"
fi
if [ "${OTA_JSON}" == "true" ] && [[ *"${OTA_LIKE}"* == "crDroid" ]]; then
    TG_URL="https://t.me/${TG_USER}"
fi

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
    echo -e "$(date +"%Y-%m-%d") $(date +"%T") W: GH_REPO is not set, the script will not able to upload builds" >> "${MY_DIR}"/buildbot_log.txt
    UPLOAD_TYPE="OFF"
fi
if [ "${UPLOAD_TYPE}" = "GH" ] && [ "${GH_USER}" = "" ]; then
    echo -e "$(date +"%Y-%m-%d") $(date +"%T") W: GH_USER is not set, the script will not able to upload builds" >> "${MY_DIR}"/buildbot_log.txt
    UPLOAD_TYPE="OFF"
fi
if [ "${UPLOAD_TYPE}" = "SF" ] && [ "${SF_USER}" = "" ]; then
    echo -e "$(date +"%Y-%m-%d") $(date +"%T") W: SF_USER is not set, the script will not able to upload builds" >> "${MY_DIR}"/buildbot_log.txt
    UPLOAD_TYPE="OFF"
fi
if [ "${UPLOAD_TYPE}" = "SF" ] && [ "${SF_PASS}" = "" ]; then
    echo -e "$(date +"%Y-%m-%d") $(date +"%T") W: SF_PASS is not set, the script will not able to upload builds" >> "${MY_DIR}"/buildbot_log.txt
    UPLOAD_TYPE="OFF"
fi
if [ "${UPLOAD_TYPE}" = "SF" ] && [ "${SF_PROJECT}" = "" ]; then
    echo -e "$(date +"%Y-%m-%d") $(date +"%T") W: SF_PROJECT is not set, the script will not able to upload builds" >> "${MY_DIR}"/buildbot_log.txt
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
    repo init -u "${REPO_URL}" -b "${REPO_BRANCH}" --git-lfs --depth=1
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
                echo -e "$(date +"%Y-%m-%d") $(date +"%T") W: MANIFEST_URL link is broken, manifest not cloned..." >> "${MY_DIR}"/buildbot_log.txt
            fi
        else
            echo -e "$(date +"%Y-%m-%d") $(date +"%T") W: you started to sync ${ROM_NAME}-${ANDROID_VERSION} without device tree manifest, which can the build machine may not able to start the build later" >> "${MY_DIR}"/buildbot_log.txt
        fi
        echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: started to sync ${ROM_NAME}-${ANDROID_VERSION}!" >> "${MY_DIR}"/buildbot_log.txt
        if [ "${TG_CHAT}" != "" ]; then
            if [ "${TG_TOPIC}" != "" ]; then
                curl -s --data parse_mode=HTML --data text="Started to sync ${ROM_NAME}-${ANDROID_VERSION}!" --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
            else
                curl -s --data parse_mode=HTML --data text="Started to sync ${ROM_NAME}-${ANDROID_VERSION}!" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
            fi
        fi
        repo sync --force-sync --no-tags --no-clone-bundle 2<&1 | tee sync.log
        REPO_SYNC_STATUS=${?}
        if ! [ -d "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}/bootable" ] && [ ${REPO_SYNC_STATUS} != 0 ]; then
            END_REPO=$(date +"%s")
            DIFF_REPO=$((END_REPO-START_REPO))
            if [ "${TG_CHAT}" != "" ]; then
                if [ "${TG_TOPIC}" != "" ]; then
                    curl -F chat_id="${TG_CHAT}" -F message_thread_id="${TG_TOPIC}" -F document=@sync.log -F caption="${ROM_NAME}-${ANDROID_VERSION} Sync failed in $((DIFF_REPO / 3600)) hours, $((DIFF_REPO % 3600 / 60)) minutes and $((DIFF_REPO % 60)) seconds!" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendDocument 2>&1 >/dev/null
                else
                    curl -F chat_id="${TG_CHAT}" -F document=@sync.log -F caption="${ROM_NAME}-${ANDROID_VERSION} Sync failed in $((DIFF_REPO / 3600)) hours, $((DIFF_REPO % 3600 / 60)) minutes and $((DIFF_REPO % 60)) seconds!" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendDocument 2>&1 >/dev/null
                fi
            fi
            echo -e "$(date +"%Y-%m-%d") $(date +"%T") E: Sync ${ROM_NAME}-${ANDROID_VERSION} done unsuccessfully, exiting..." >> "${MY_DIR}"/buildbot_log.txt
            return 1
        else
            END_REPO=$(date +"%s")
            DIFF_REPO=$((END_REPO-START_REPO))
            echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: Sync ${ROM_NAME}-${ANDROID_VERSION} done successfully, starting to build..." >> "${MY_DIR}"/buildbot_log.txt
            if [ "${TG_CHAT}" != "" ]; then
                if [ "${TG_TOPIC}" != "" ]; then
                    curl -s --data parse_mode=HTML --data text="${ROM_NAME}-${ANDROID_VERSION} source synced successfully! It's took $((DIFF_REPO / 3600)) hours, $((DIFF_REPO % 3600 / 60)) minutes and $((DIFF_REPO % 60)) seconds!" --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot$TG_TOKEN/sendMessage 2>&1 >/dev/null
                    curl -s --data parse_mode=HTML --data text="The sync succedded, Starting to build..." --data chat_id=$TG_CHAT --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                else
                    curl -s --data parse_mode=HTML --data text="${ROM_NAME}-${ANDROID_VERSION} source synced successfully! It's took $((DIFF_REPO / 3600)) hours, $((DIFF_REPO % 3600 / 60)) minutes and $((DIFF_REPO % 60)) seconds!" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot$TG_TOKEN/sendMessage 2>&1 >/dev/null
                    curl -s --data parse_mode=HTML --data text="The sync succedded, Starting to build..." --data chat_id=$TG_CHAT --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                fi
            fi
        fi
    fi
}

## Build
build() {
    cd "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}"
    SYNC_BEFORE_BUILD="${SYNC_BEFORE_BUILD:=True}"
    if [ "${SYNC_BEFORE_BUILD}" == "True" ]; then
        repo sync --force-sync --no-tags --no-clone-bundle
    fi
    source build/envsetup.sh
    for CODENAME in ${DEVICE_CODENAME}
    do
        BUILD_STATUS=""
        if [ -e "${MY_DIR}"/.buildstatus ]; then
            rm "${MY_DIR}"/.buildstatus
        fi
        if [ "${AUTO_ADAPT}" == "Y" ] || [ "${AUTO_ADAPT}" == "yes" ] || [ "${AUTO_ADAPT}" == "Yes" ]; then
            echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: started to adapt device tree for ${CODENAME}!" >> "${MY_DIR}"/buildbot_log.txt
            VENDOR_NAME="$(find ./device ~ -type d -name "${CODENAME}" | sort -nr | awk 'NR==1,NR==1')"
            if [ "${VENDOR_NAME}" == "" ]
            then
                break 1
            fi
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
                if [ "${TG_TOPIC}" != "" ]; then
                    curl -F document=@lunch.log -F caption="lunch for ${CODENAME} failed."  -F message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendDocument?chat_id="${TG_CHAT}" 2>&1 >/dev/null
                else
                    curl -F document=@lunch.log -F caption="lunch for ${CODENAME} failed." --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendDocument?chat_id="${TG_CHAT}" 2>&1 >/dev/null
                fi
            fi
            if [ "${AUTO_ADAPT}" == "Y" ] || [ "${AUTO_ADAPT}" == "yes" ] || [ "${AUTO_ADAPT}" == "Yes" ]; then
                echo -e "$(date +"%Y-%m-%d") $(date +"%T") E: Adapt device tree for ${CODENAME} failed!" >> "${MY_DIR}"/buildbot_log.txt
                echo -e "$(date +"%Y-%m-%d") $(date +"%T") F: lunch for ${CODENAME} failed." >> "${MY_DIR}"/buildbot_log.txt
                echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: Please dm @Orel6505 and send him terminal log and tell him to fix auto adapt" >> "${MY_DIR}"/buildbot_log.txt
            else
                echo -e "$(date +"%Y-%m-%d") $(date +"%T") F: lunch for ${CODENAME} failed." >> "${MY_DIR}"/buildbot_log.txt
            fi
            break 1
        else
            sed -i "/Trying dependencies-only mode on a/c\ " lunch.log
            sed -i '/^\s*$/d' lunch.log
            if [ "${TG_CHAT}" != "" ]; then
                if [ "${TG_USER}" != "" ]; then
                    if [ "${TG_TOPIC}" != "" ]; then
                        BUILD_MESSAGE=$(curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
👤 Builder: <code>${TG_USER}</code>
Build Status: Build Started" --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage | cut -f4 -d ':' | cut -f1 -d ',')
                    else
                        BUILD_MESSAGE=$(curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
👤 Builder: <code>${TG_USER}</code>
Build Status: Build Started" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage | cut -f4 -d ':' | cut -f1 -d ',')
                    fi
                else
                    if [ "${TG_TOPIC}" != "" ]; then
                        BUILD_MESSAGE=$(curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
Build Status: Build Started" --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage | cut -f4 -d ':' | cut -f1 -d ',')
                    else
                        BUILD_MESSAGE=$(curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
Build Status: Build Started" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage | cut -f4 -d ':' | cut -f1 -d ',')
                    fi
                fi
            fi
            echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: build for ${CODENAME} started!"  >> "${MY_DIR}"/buildbot_log.txt
            if [ "${TG_CHAT}" != "" ]; then
                buildstatus &
            fi
            [ "${BUILD_J}" != "" ]; then
                make ${BACON_NAME} -j ${BUILD_J}
            else
                make ${BACON_NAME}
            fi
            BUILD_STATUS=${?}
            if [ "${TG_CHAT}" != "" ]; then
                echo $BUILD_STATUS > "${MY_DIR}"/.buildstatus
                wait
            fi
            if [ "${BUILD_STATUS}" != 0 ]; then
	            END_BUILD=$(date +"%s")
	            DIFF_BUILD=$((END_BUILD-START_BUILD))
                if [ "${TG_CHAT}" != "" ]; then
                    if [ "${TG_TOPIC}" != "" ]; then
                        curl -F chat_id="${TG_CHAT}" -F message_thread_id="${TG_TOPIC}" -F document=@out/error.log -F caption="The ${ROM_NAME}-${ANDROID_VERSION} build for ${CODENAME} failed in $((DIFF_BUILD / 3600)) hours, $((DIFF_BUILD % 3600 / 60)) minutes and $((DIFF_BUILD % 60)) seconds!" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendDocument 2>&1 >/dev/null
                    else
                        curl -F chat_id="${TG_CHAT}" -F document=@out/error.log -F caption="The ${ROM_NAME}-${ANDROID_VERSION} build for ${CODENAME} failed in $((DIFF_BUILD / 3600)) hours, $((DIFF_BUILD % 3600 / 60)) minutes and $((DIFF_BUILD % 60)) seconds!" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendDocument 2>&1 >/dev/null
                    fi
                fi
                echo -e "$(date +"%Y-%m-%d") $(date +"%T") E: build for ${CODENAME} failed."  >> "${MY_DIR}"/buildbot_log.txt
                break 1
            else
                END_BUILD=$(date +"%s")
	            DIFF_BUILD=$((END_BUILD-START_BUILD))
                echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: build for ${CODENAME} done successfully!"  >> "${MY_DIR}"/buildbot_log.txt
                if [ "${TG_CHAT}" != "" ]; then
                    if [ "${TG_TOPIC}" != "" ]; then
                        curl -s --data parse_mode=HTML --data text="The ${ROM_NAME}-${ANDROID_VERSION} build for ${CODENAME} succeed!
The build took $((DIFF_BUILD / 3600)) hours, $((DIFF_BUILD % 3600 / 60)) minutes and $((DIFF_BUILD % 60)) seconds!" --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                    else
                        curl -s --data parse_mode=HTML --data text="The ${ROM_NAME}-${ANDROID_VERSION} build for ${CODENAME} succeed!
The build took $((DIFF_BUILD / 3600)) hours, $((DIFF_BUILD % 3600 / 60)) minutes and $((DIFF_BUILD % 60)) seconds!" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                    fi
                fi
                cd "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}"/out/target/product/"${CODENAME}"
                ROM_ZIP=$(find -type f -name "*${CODENAME}*.zip" -exec stat -c '%Y %n' {} \; | sort -nr | head -n 20 | awk 'NR==1,NR==1 {print $2}')
                ROM_ZIP=$(basename "${ROM_ZIP}")
                ROM_ZIP_KNOX="0x1"
                ENG_KNOX="1"
                while [ "${ROM_ZIP_KNOX}" == "0x1" ]; do
                    if ! [[ "${ROM_ZIP}" == *"eng"* ]]; then
                        ROM_ZIP_KNOX="0x0"
                    else
                        ROM_ZIP=$(find -type f -name "*${CODENAME}*.zip" -exec stat -c '%Y %n' {} \; | sort -nr | head -n 20 | awk '{print $2}' NR=="${ENG_KNOX}",NR=="${ENG_KNOX}")
                        ENG_KNOX=$(expr "${ENG_KNOX}" + 1)
                    fi
                done
                ROM_SIZE=$(ls -lh "${ROM_ZIP}" | cut -f5 -d " ")
                ROM_SIZE_BYTES=$(ls -l "${ROM_ZIP}" | cut -f5 -d " ")
                ROM_ID=$(sha256sum "${ROM_ZIP}" | cut -f1 -d " ")
                ROM_HASH=$(md5sum "${ROM_ZIP}" | cut -f1 -d " ")
                METADATA=$(unzip -p "${ROM_ZIP}" META-INF/com/android/metadata)
                SDK_LEVEL=$(echo "${METADATA}" | grep post-sdk-level | cut -f2 -d '=')
                TIMESTAMP=$(echo "${METADATA}" | grep post-timestamp | cut -f2 -d '=')
                if [ -e recovery.img ] && [ "${UPLOAD_RECOVERY}" = "true" ]; then
                    RECOVERY_IMG="recovery.img"
                    RECOVERY_HASH=$(sha256sum "${RECOVERY_IMG}" | cut -f1 -d " ")
                fi
                if [ "${OTA_JSON}" == "true" ]; then
                    if [ "${UPLOAD_TYPE}" = "GD" ]; then
                        if [ "${CUSTOM_ROM_ZIP_DOWNLOAD_URL}" != "" ]; then
                            URL="${CUSTOM_ROM_ZIP_DOWNLOAD_URL}"
                        fi
                    elif [ "${UPLOAD_TYPE}" = "GH" ]; then
                        if [ "${CUSTOM_ROM_ZIP_DOWNLOAD_URL}" != "" ]; then
                            URL="${CUSTOM_ROM_ZIP_DOWNLOAD_URL}"
                        else
                            URL="https://github.com/${GH_NAME}/${GH_REPO}/releases/download/${ROM_ZIP}/${ROM_ZIP}"
                        fi
                    elif [ "${UPLOAD_TYPE}" = "SF" ]; then
                        if [ "${CUSTOM_ROM_ZIP_DOWNLOAD_URL}" != "" ]; then
                            URL="${CUSTOM_ROM_ZIP_DOWNLOAD_URL}/${ROM_ZIP}"
                        else
                            if [ "${SF_PATH}" != "" ]; then
                                URL="https://sourceforge.net/projects/${SF_PROJECT}/files/${CODNAME}/${SF_PATH}/${ROM_ZIP}/download"
                            else
                                URL="https://sourceforge.net/projects/${SF_PROJECT}/files/${CODNAME}/${ROM_NAME}-${ANDROID_VERSION}/${ROM_ZIP}/download"
                            fi
                        fi
                    elif [ "${UPLOAD_TYPE}" = "FTP" ]; then
                        URL="${CUSTOM_ROM_ZIP_DOWNLOAD_URL}"
                    fi
                    KNOX_OFFICIAL=1
                    until [ ${KNOX_OFFICIAL} -gt 7 ]; do 
                        KNOX_TMP2=$(echo "${ROM_ZIP}" | cut -f"${KNOX_OFFICIAL}" -d '-')
                        if [[ *"${KNOX_TMP2}"* = "OFFICIAL" ]]; then
                            KNOX_OFFICIAL="OFFICIAL"
                            break 1
                        else
                            KNOX_OFFICIAL=$(expr "${KNOX_OFFICIAL}" + 1)
                        fi
                    done
                    if [ ${KNOX_OFFICIAL} == "7" ]; then
                        KNOX_OFFICIAL="UNOFFICIAL"
                    fi
                fi

                #if Github release
                if [ "${UPLOAD_TYPE}" == "GH" ]; then
                    GH_TAG="${ROM_NAME}-${ANDROID_VERSION}-${CODENAME}-$(date +"%Y-%m-%d")"
                    if [ "${UPLOAD_RECOVERY}" = "true" ]; then
                        GH_RELEASE_NOTES="rom sha256: ${ROM_ID}
recovery sha256: ${RECOVERY_HASH}"
                    else
                        GH_RELEASE_NOTES="sha256: ${ROM_ID}"
                    fi
                    if ! [ -d "${MY_DIR}"/"${GH_REPO}" ]; then
                        git clone "${GH_REPO_URL}" "${MY_DIR}"/"${GH_REPO}"
                    fi
                    if ! [ -d "${MY_DIR}"/"${GH_REPO}"/"${ROM_ZIP}" ]; then
                        cp "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}"/out/target/product/"${CODENAME}"/"${ROM_ZIP}" "${MY_DIR}"/"${GH_REPO}"
                        if ! [ -d "${MY_DIR}"/"${GH_REPO}"/"${RECOVERY_IMG}" ] && [ "${UPLOAD_RECOVERY}" == "true" ]; then
                            cp "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}"/out/target/product/"${CODENAME}"/"${RECOVERY_IMG}" "${MY_DIR}"/"${GH_REPO}"
                        fi
                    fi
                    cd "${MY_DIR}"/"${GH_REPO}"
                    if ! [ $(git tag -l "${GH_TAG}") ]; then
                        git tag "${GH_TAG}"
                        git push --repo="${GH_PUSH_URL}" --tags
                    fi
                    echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: starting to upload to Github"  >> "${MY_DIR}"/buildbot_log.txt
                    if [ "${UPLOAD_RECOVERY}" = "true" ]; then
                        if [ "${CREATE_OTA_JSON}" = "true" ]; then
                            gh release create "${GH_TAG}" -t "OTA: ${ROM_NAME}-${CODENAME}: $(date +"%Y-%m-%d")" -n "${GH_RELEASE_NOTES}" "${ROM_ZIP}" "${RECOVERY_IMG}"
                        else
                            gh release create "${GH_TAG}" -t "${ROM_NAME}-${CODENAME}: $(date +"%Y-%m-%d")" -n "${GH_RELEASE_NOTES}" "${ROM_ZIP}" "${RECOVERY_IMG}"
                        fi
                    else
                        if [ "${CREATE_OTA_JSON}" = "true" ]; then
                            gh release create "${GH_TAG}" -t "OTA: ${ROM_NAME}-${CODENAME}: $(date +"%Y-%m-%d")" -n "${GH_RELEASE_NOTES}" "${ROM_ZIP}"
                        else
                            gh release create "${GH_TAG}" -t "${ROM_NAME}-${CODENAME}: $(date +"%Y-%m-%d")" -n "${GH_RELEASE_NOTES}" "${ROM_ZIP}"
                        fi
                    fi
                    if [ "${TG_CHAT}" != "" ]; then
                        if [ "${TG_TOPIC}" != "" ]; then
                            curl -s --data parse_mode=HTML --data text="Upload ${ROM_ZIP} for ${CODENAME} succeed!" --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                            curl -s --data parse_mode=HTML --data text="📱 <b>New build available for ${CODENAME}</b>
👤 by ${TG_USER}

ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
📅 Build date: <code>$(date +"%d-%m-%Y")</code>
📎 File size: <code>${ROM_SIZE}</code>
✅ SHA256: <code>${ROM_ID}</code>" --data reply_markup="{\"inline_keyboard\": [[{\"text\":\"Download!\", \"url\": \"https://github.com/${GH_USER}/${GH_REPO}/${GH_RELEASE}\"}]]}" --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                        else
                            curl -s --data parse_mode=HTML --data text="Upload ${ROM_ZIP} for ${CODENAME} succeed!" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                            curl -s --data parse_mode=HTML --data text="📱 <b>New build available for ${CODENAME}</b>
👤 by ${TG_USER}

ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
📅 Build date: <code>$(date +"%d-%m-%Y")</code>
📎 File size: <code>${ROM_SIZE}</code>
✅ SHA256: <code>${ROM_ID}</code>" --data reply_markup="{\"inline_keyboard\": [[{\"text\":\"Download!\", \"url\": \"https://github.com/${GH_USER}/${GH_REPO}/${GH_RELEASE}\"}]]}" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                        fi
                    fi
                    echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: Upload ${ROM_ZIP} for ${CODENAME} done successfully!"  >> "${MY_DIR}"/buildbot_log.txt
                    rm "${ROM_ZIP}"
                    if [ "${UPLOAD_RECOVERY}" == "true" ]; then
                        rm "${RECOVERY_IMG}"
                    fi
                fi

                #if sourceforge release
                if [ "${UPLOAD_TYPE}" == "SF" ]; then
                    if [ "${SF_PATH}" == "" ]; then
                        echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: starting to upload to SourceForge"  >> "${MY_DIR}"/buildbot_log.txt
			            sshpass -p "${SF_PASS}" scp ${ROM_ZIP} ${SF_USER}@frs.sourceforge.net:/home/frs/project/${SF_PROJECT}/${CODENAME}/${ROM_NAME}-${ANDROID_VERSION}
                        if [ "${UPLOAD_RECOVERY}" = "true" ]; then
                            sshpass -p "${SF_PASS}" scp ${RECOVERY_IMG} ${SF_USER}@frs.sourceforge.net:/home/frs/project/${SF_PROJECT}/${CODENAME}/${ROM_NAME}-${ANDROID_VERSION}
                        fi
                        if [ "${TG_CHAT}" != "" ]; then
			                curl -s --data parse_mode=HTML --data text="Upload ${ROM_ZIP} for ${CODENAME} succeed!" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                            curl -s --data parse_mode=HTML --data text="📱 <b>New build available for ${CODENAME}</b>
👤 by ${TG_USER}

ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
📅 Build date: <code>$(date +"%d-%m-%Y")</code>
📎 File size: <code>${ROM_SIZE}</code>
✅ SHA256: <code>${ROM_ID}</code>" --data reply_markup="{\"inline_keyboard\": [[{\"text\":\"Download!\", \"url\": \"https://sourceforge.net/projects/${SF_PROJECT}/files/${CODENAME}/\"}]]}" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
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
                            if [ "${TG_TOPIC}" != "" ]; then
			                    curl -s --data parse_mode=HTML --data text="Upload ${ROM_ZIP} for ${CODENAME} succeed!" --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                                curl -s --data parse_mode=HTML --data text="📱 <b>New build available for ${CODENAME}</b>
👤 by ${TG_USER}

ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
📅 Build date: <code>$(date +"%d-%m-%Y")</code>
📎 File size: <code>${ROM_SIZE}</code>
✅ SHA256: <code>${ROM_ID}</code>" --data reply_markup="{\"inline_keyboard\": [[{\"text\":\"Download!\", \"url\": \"https://sourceforge.net/projects/${SF_PROJECT}/files/${SF_PATH}/\"}]]}" --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                            else
			                    curl -s --data parse_mode=HTML --data text="Upload ${ROM_ZIP} for ${CODENAME} succeed!" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                                curl -s --data parse_mode=HTML --data text="📱 <b>New build available for ${CODENAME}</b>
👤 by ${TG_USER}

ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
📅 Build date: <code>$(date +"%d-%m-%Y")</code>
📎 File size: <code>${ROM_SIZE}</code>
✅ SHA256: <code>${ROM_ID}</code>" --data reply_markup="{\"inline_keyboard\": [[{\"text\":\"Download!\", \"url\": \"https://sourceforge.net/projects/${SF_PROJECT}/files/${SF_PATH}/\"}]]}" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                            fi
                        fi
                    fi
                fi

                #if FTP
                if [ "${UPLOAD_TYPE}" == "FTP" ]; then
                    echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: starting to upload to FTP server"  >> "${MY_DIR}"/buildbot_log.txt
                    curl --ssl -k --user "${FTP_USER}":"${FTP_PASS}" -T "${ROM_ZIP}" ftp://"${FTP_UPLOAD_URL}"
                    if [ "${UPLOAD_RECOVERY}" = "true" ]; then
                        curl --ssl -k --user "${FTP_USER}":"${FTP_PASS}" -T "${RECOVERY_IMG}" ftp://"${FTP_UPLOAD_URL}"
                    fi
                    echo -e "$(date +"%Y-%m-%d") $(date +"%T") I: upload to FTP server done successfully"  >> "${MY_DIR}"/buildbot_log.txt
                    if [ "${TG_CHAT}" != "" ]; then
                        if [ "${TG_TOPIC}" != "" ]; then
			                curl -s --data parse_mode=HTML --data text="Upload ${ROM_ZIP} for ${CODENAME} succeed!" --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                            curl -s --data parse_mode=HTML --data text="📱 <b>New build available for ${CODENAME}</b>
👤 by ${TG_USER}

ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
📅 Build date: <code>$(date +"%d-%m-%Y")</code>
📎 File size: <code>${ROM_SIZE}</code>
✅ SHA256: <code>${ROM_ID}</code>" --data reply_markup="{\"inline_keyboard\": [[{\"text\":\"Download!\", \"url\": \"https://sourceforge.net/projects/${SF_PROJECT}/files/${SF_PATH}/\"}]]}" --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                        else
			                curl -s --data parse_mode=HTML --data text="Upload ${ROM_ZIP} for ${CODENAME} succeed!" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                            curl -s --data parse_mode=HTML --data text="📱 <b>New build available for ${CODENAME}</b>
👤 by ${TG_USER}

ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
📅 Build date: <code>$(date +"%d-%m-%Y")</code>
📎 File size: <code>${ROM_SIZE}</code>
✅ SHA256: <code>${ROM_ID}</code>" --data reply_markup="{\"inline_keyboard\": [[{\"text\":\"Download!\", \"url\": \"https://sourceforge.net/projects/${SF_PROJECT}/files/${SF_PATH}/\"}]]}" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 2>&1 >/dev/null
                        fi
                    fi
                fi

                #if OTA
                if [ "${OTA_JSON}" == "true" ]; then
                    if ! [ -d "${MY_DIR}"/"${GH_REPO}" ]; then
                        git clone "${GH_REPO_URL}" "${MY_DIR}"/"${GH_REPO}"
                    fi
                    cd "${MY_DIR}"/"${GH_REPO}"
                    if [ "${OTA_LIKE}" = "lineage" ] || [ "${OTA_LIKE}" = "LOS" ]; then
                        JSON_FORMAT='{\n  "response": [\n    {\n      "filename": "%s",\n      "id": "%s",\n      "size": "%s",\n      "datetime": "%s",\n      "url": "%s",\n      "version": "%s"\n    },\n  ]\n}'
                        printf "${JSON_FORMAT}" "${ROM_ZIP}" "${ROM_ID}" "${ROM_SIZE_BYTES}" "${TIMESTAMP}" "${URL}" "${REPO_BRANCH}"  > ${CODENAME}.json
                        git add ${CODENAME}.json
                        git commit -m "OTA: ${ROM_NAME}-${CODENAME}: $(date +"%Y-%m-%d")"
                        git push --repo="${GH_PUSH_URL}"
                    elif [ "${OTA_LIKE}" = "PE" ] || [ "${OTA_LIKE}" = "PixelExperience" ]; then
                        JSON_FORMAT='{\n    "error": false,\n    "filename": "%s",\n    "filehash": "%s",\n    "id": "%s",\n    "datetime": "%s",\n    "size": "%s",\n'
                        printf "${JSON_FORMAT}" "${ROM_ZIP}" "${ROM_HASH}" "${ROM_ID}" "${TIMESTAMP}" "${ROM_SIZE_BYTES}" > ${CODENAME}.json
                        printf '    "maintainers": [\n' >> ${CODENAME}.json
                        if [ "${MAINTAINER_COUNT}" != 1 ]; then
                            TMP1=1
                            for MAINTAINER in $MAINTAINERS_A; do
                                GH_MAINTAINER=$(echo "${GH_MAINTAINERS}" | cut -d "&" -f"${TMP1}"  | sed 's/ //g')
                                if [ "${TMP1}" = 1 ]; then
                                    MAIN_MAINTAINER=true
                                    printf '        {\n            "main_maintainer": %s,\n            "name": "%s",\n            "github_username": "%s",\n        }' "${MAIN_MAINTAINER}" "${MAINTAINER}" "${GH_MAINTAINER}" >> ${CODENAME}.json
                                else
                                    MAIN_MAINTAINER=false
                                    printf '        {\n            "main_maintainer": %s,\n            "name": "%s",\n            "github_username": "%s",\n        }' "${MAIN_MAINTAINER}" "${MAINTAINER}" "${GH_MAINTAINER}" >> ${CODENAME}.json
                                fi
                                TMP1=$(expr "${TMP1}" + 1)
                                if ! [ "${TMP1}" -gt  "${MAINTAINER_COUNT}" ]; then
                                    printf ',\n' >> ${CODENAME}.json
                                else
                                    printf '\n' >> ${CODENAME}.json
                                fi
                            done
                            printf '    ],\n' >> ${CODENAME}.json
                        else
                            MAIN_MAINTAINER=false
                            GH_MAINTAINER=$(echo "${GH_MAINTAINERS}" | sed 's/ //g')
                            printf '        {\n            "main_maintainer": %s,\n            "name": "%s",\n            "github_username": "%s",\n        }' "${MAIN_MAINTAINER}" "${MAINTAINER}" "${GH_MAINTAINER}" >> ${CODENAME}.json
                            printf ',\n' >> ${CODENAME}.json
                            printf '    ],\n' >> ${CODENAME}.json
                        fi
                        JSON_FORMAT='    "donate_url": "%s",\n    "news_url": "%s",\n    "url": "%s",\n    "version": "%s",\n    "website_url": "%s"\n}'
                        printf "${JSON_FORMAT}" "${DONATE_URL}" "${NEWS_URL}" "${URL}" "${REPO_BRANCH}" "${WEBSITE_URL}" >> ${CODENAME}.json
                        git add ${CODENAME}.json
                        git commit -m "OTA: ${ROM_NAME}-${CODENAME}: $(date +"%Y-%m-%d")"
                        git push --repo="${GH_PUSH_URL}"
                    elif [ "${OTA_LIKE}" = "crDroid" ] && [ "${ANDROID_VERSION}" = "12" ] || [ "${OTA_LIKE}" = "crDroid" ] && [ "${ANDROID_VERSION}" = "12.1" ]; then
                        JSON_FORMAT='{\n  "response": [\n    {\n        "maintainer": "%s",\n        "filename": "%s",\n        "download": "%s",\n        "timestamp": "%s",\n        "md5": "%s",\n        "sha256": "%s",\n        "size": "%s",\n        "version": "%s",\n        "buildtype": "%s",\n        "forum": "%s",\n        "gapps": "%s",\n        "firmware": "%s",\n        "modem": "%s",\n        "bootloader": "%s",\n        "recovery": "%s",\n        "paypal": "%s",\n        "telegram": "%s",\n    }\n  ]\n}'
                        printf "${JSON_FORMAT}" "${MAINTAINERS}" "${ROM_ZIP}" "${URL}" "${TIMESTAMP}" "${ROM_HASH}" "${ROM_ID}" "${ROM_SIZE_BYTES}" "${REPO_BRANCH}" "${BUILD_TYPE}" "${XDA_TREAD}" "${GAPPS_URL}" "${FIRMWARE_URL}" "${MODEM_URL}" "${BOOTLOADER_URL}" "${RECOVERY_URL}" "${DONATE_URL}" "${TG_URL}" > ${CODENAME}.json
                        git add ${CODENAME}.json
                        git commit -m "OTA: ${ROM_NAME}-${CODENAME}: $(date +"%Y-%m-%d")"
                        git push --repo="${GH_PUSH_URL}"
                    elif [ "${OTA_LIKE}" = "crDroid" ] && [ "${ANDROID_VERSION}" = "11" ]; then
                        JSON_FORMAT='{\n  "response": [\n    {\n        "maintainer": "%s",\n        "filename": "%s",\n        "download": "%s",\n        "timestamp": "%s",\n        "md5": "%s",\n        "size": "%s",\n        "version": "%s",\n        "buildtype": "%s",\n        "forum": "%s",\n        "gapps": "%s",\n        "firmware": "%s",\n        "modem": "%s",\n        "bootloader": "%s",\n        "recovery": "%s",\n        "paypal": "%s",\n        "telegram": "%s",\n    }\n  ]\n}'
                        printf "${JSON_FORMAT}" "${MAINTAINERS}" "${ROM_ZIP}" "${URL}" "${TIMESTAMP}" "${ROM_HASH}" "${ROM_SIZE_BYTES}" "${REPO_BRANCH}" "${BUILD_TYPE}" "${XDA_TREAD}" "${GAPPS_URL}" "${FIRMWARE_URL}" "${MODEM_URL}" "${BOOTLOADER_URL}" "${RECOVERY_URL}" "${DONATE_URL}" "${TG_URL}" > ${CODENAME}.json
                        git add ${CODENAME}.json
                        git commit -m "OTA: ${ROM_NAME}-${CODENAME}: $(date +"%Y-%m-%d")"
                        git push --repo="${GH_PUSH_URL}"
                    elif [ "${OTA_LIKE}" = "Evox" ] || [ "${OTA_LIKE}" = "Evolution" ]; then
                        JSON_FORMAT='{\n  "error": false,\n  "filename": "%s",\n  "filehash": "%s",\n  "id": "%s",\n  "datetime":"%s",\n  "size": "%s",\n  "version": "%s",\n  "maintainer": "%s",\n  "telegram_username": "%s",\n  "url":, "%s",\n  "maintainer_url": "%s",\n  "news_url": "%s",\n  "forum_url": "%s",\n  "website_url": "%s",\n  "donate_url": "%s"\n}'
                        printf "${JSON_FORMAT}" "${ROM_ZIP}" "${ROM_HASH}" "${ROM_ID}" "${TIMESTAMP}" "${ROM_SIZE_BYTES}" "${REPO_BRANCH}" "${MAINTAINERS}" "${TG_USER}" "${URL}" "${MAINTAINER_URL}" "${NEWS_URL}" "${XDA_TREAD}" "${WEBSITE_URL}" "${DONATE_URL}" > ${CODENAME}.json
                        git add ${CODENAME}.json
                        git commit -m "OTA: ${ROM_NAME}-${CODENAME}: $(date +"%Y-%m-%d")"
                        git push --repo="${GH_PUSH_URL}"
                    else
                        echo -e "$(date +"%Y-%m-%d") $(date +"%T") E: OTA: did you set something wrong?" >> "${MY_DIR}"/buildbot_log.txt
                        echo -e "$(date +"%Y-%m-%d") $(date +"%T") E: OTA: disabing OTA..." >> "${MY_DIR}"/buildbot_log.txt
                        OTA_JSON="false"
                    fi
                fi
                if ! [ -z "${GH_REPO}" ] && [ -d "${MY_DIR}"/"${GH_REPO}" ]; then
                    rm -fr "${MY_DIR}"/"${GH_REPO}"
                fi
                cd "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}"
            fi
        fi
    done
}

buildstatus() {
    while true; do
        STATUS_KNOX1=$(protoc --decode_raw < "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}"/out/build_progress.pb | cut -c 4- | head -1)
        STATUS_KNOX2=$(protoc --decode_raw < "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}"/out/build_progress.pb | cut -b 4-  | head -n 2 | tail -n 1)
        BUILD_PRECENT="$(echo "scale=2; $STATUS_KNOX2 / $STATUS_KNOX1*100" | bc)"
        if [ "${TG_USER}" != "" ]; then
            if [ "${TG_TOPIC}" != "" ]; then
                curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
👤 Builder: <code>${TG_USER}</code>
Build Status: ${BUILD_PRECENT}" --data message_id=${BUILD_MESSAGE} --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/editMessageText 2>&1 >/dev/null
            else
                curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
👤 Builder: <code>${TG_USER}</code>
Build Status: ${BUILD_PRECENT}" --data message_id=${BUILD_MESSAGE} --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/editMessageText 2>&1 >/dev/null
            fi
        else
            if [ "${TG_TOPIC}" != "" ]; then
                curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION}</code>
Build Status: ${BUILD_PRECENT}" --data message_id=${BUILD_MESSAGE} --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/editMessageText 2>&1 >/dev/null
            else
                curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION}</code>
Build Status: ${BUILD_PRECENT}" --data message_id=${BUILD_MESSAGE} --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/editMessageText 2>&1 >/dev/null
            fi
        fi
        if [ -e "${MY_DIR}"/.buildstatus ]; then
            break
        fi
        sleep 3m
    done
    if [ "$(cat "${MY_DIR}"/.buildstatus)" = 0 ]; then
        rm "${MY_DIR}"/.buildstatus
        if [ "${TG_USER}" != "" ]; then
            if [ "${TG_TOPIC}" != "" ]; then
                curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
👤 Builder: <code>${TG_USER}</code>
Build Status: <b>Build Success</b>" --data message_id=${BUILD_MESSAGE} --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/editMessageText 2>&1 >/dev/null
            else
                curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
👤 Builder: <code>${TG_USER}</code>
Build Status: <b>Build Success</b>" --data message_id=${BUILD_MESSAGE} --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/editMessageText 2>&1 >/dev/null
            fi
        else
            if [ "${TG_TOPIC}" != "" ]; then
                curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION}</code>
Build Status: <b>Build Success</b>" --data message_id=${BUILD_MESSAGE} --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/editMessageText 2>&1 >/dev/null
            else
                curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION}</code>
Build Status: <b>Build Success</b>" --data message_id=${BUILD_MESSAGE} --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/editMessageText 2>&1 >/dev/null
            fi
        fi
    elif [ "$(cat "${MY_DIR}"/.buildstatus)" != 0 ]; then
        rm "${MY_DIR}"/.buildstatus
        if [ "${TG_USER}" != "" ]; then
            if [ "${TG_TOPIC}" != "" ]; then
                curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
👤 Builder: <code>${TG_USER}</code>
Build Status: <b>Build Failed</b>" --data message_id=${BUILD_MESSAGE} --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/editMessageText 2>&1 >/dev/null
            else
                curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
👤 Builder: <code>${TG_USER}</code>
Build Status: <b>Build Failed</b>" --data message_id=${BUILD_MESSAGE} --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/editMessageText 2>&1 >/dev/null
            fi
        else
            if [ "${TG_TOPIC}" != "" ]; then
                curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION}</code>
Build Status: <b>Build Failed</b>" --data message_id=${BUILD_MESSAGE} --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/editMessageText 2>&1 >/dev/null
            else
                curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION}</code>
Build Status: <b>Build Failed</b>" --data message_id=${BUILD_MESSAGE} --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/editMessageText 2>&1 >/dev/null
            fi
        fi
    else
        rm "${MY_DIR}"/.buildstatus
        if [ "${TG_USER}" != "" ]; then
            if [ "${TG_TOPIC}" != "" ]; then
                curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
👤 Builder: <code>${TG_USER}</code>
Build Status: <b>Build Status Unknown</b>" --data message_id=${BUILD_MESSAGE} --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/editMessageText 2>&1 >/dev/null
            else
                curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION} </code>
👤 Builder: <code>${TG_USER}</code>
Build Status: <b>Build Status Unknown</b>" --data message_id=${BUILD_MESSAGE} --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/editMessageText 2>&1 >/dev/null
            fi
        else
            if [ "${TG_TOPIC}" != "" ]; then
                curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION}</code>
Build Status: <b>Build Status Unknown</b>" --data message_id=${BUILD_MESSAGE} --data chat_id="${TG_CHAT}" --data message_thread_id="${TG_TOPIC}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/editMessageText 2>&1 >/dev/null
            else
                curl -s --data parse_mode=HTML --data text="<b>Build started for ${CODENAME}</b>
ℹ️ ROM: <code>${ROM_NAME}</code>
🔸 Android version: <code>${ANDROID_VERSION}</code>
Build Status: <b>Build Status Unknown</b>" --data message_id=${BUILD_MESSAGE} --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/editMessageText 2>&1 >/dev/null
            fi
        fi
    fi
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
