#!/bin/bash

#
# Orel6505
#

## Sync
sync() {
    if ! [ -d "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}" ]; then
        mkdir "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}"
    fi
    cd "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}"
    START_REPO=$(date +"%s")
    repo init -u "${REPO_URL}" -b "${REPO_BRANCH}" --depth=1
    if [ -d ".repo/local_manifests" ]; then
        rm -fr ".repo/local_manifests"
    fi
    git clone "${MANIFEST_URL}" -b "${MANIFEST_BRANCH}" .repo/local_manifests
    if [ "${TG_CHAT}" != "" ]; then
        curl -s --data parse_mode=HTML --data text="Startd to sync ${ROM_NAME}!" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 
    else 
        echo "Startd to sync ${ROM_NAME}!"
    fi
    repo sync --force-sync --no-tags --no-clone-bundle
    if ! [ -d "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}/bootable" ]; then 
        END_REPO=$(date +"%s")
        DIFF_REPO=$((END_REPO-START_REPO))
        if [ "${TG_CHAT}" != "" ]; then
            curl -s --data parse_mode=HTML --data text="${ROM_NAME} Sync failed in $((DIFF_REPO / 3600)) hours, $((DIFF_REPO % 3600 / 60)) minutes and $((DIFF_REPO % 60)) seconds!
"${TG_USERNAME}" don't be lazy and open build machine for errors" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 
        else
            echo "Sync failed in $((DIFF_REPO / 3600)) hours, $((DIFF_REPO % 3600 / 60)) minutes and $((DIFF_REPO % 60)) seconds!"
        fi
        curl -s --data parse_mode=HTML --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendSticker
        return 1
    else
        END_REPO=$(date +"%s")
        DIFF_REPO=$((END_REPO-START_REPO))
        if [ "${TG_CHAT}" != "" ]; then
            curl -s --data parse_mode=HTML --data text="${ROM_NAME} source synced successfully! It's took $((DIFF_REPO / 3600)) hours, $((DIFF_REPO % 3600 / 60)) minutes and $((DIFF_REPO % 60)) seconds!" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot$TG_TOKEN/sendMessage 
            curl -s --data parse_mode=HTML --data text="The sync succedded, Starting to build..." --data chat_id=$TG_CHAT --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 
        else
            echo "The sync succedded, Starting to build..." 
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
        lunch "${LUNCH_NAME}"_"${CODENAME}"-userdebug
        START_BUILD=$(date +"%s")
        if [ -e "{${OUT_DIR}"/out/target/product/"${CODENAME}"/build_fingerprint.txt ]; then
	        END_BUILD=$(date +"%s")
	        DIFF_BUILD=$((END_BUILD-START_BUILD))
            if [ "${TG_CHAT}" != "" ]; then
	            curl -s --data parse_mode=HTML --data text="dumpvars for ${CODENAME} failed.
"${TG_USERNAME}" don't be lazy and open build machine for errors" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage
                curl -s --data parse_mode=HTML --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendSticker
            else
                echo "dumpvars for ${CODENAME} failed."
            fi
            return 1
        fi
        if [ "${TG_CHAT}" != "" ]; then
            curl -s --data parse_mode=HTML --data text="${ROM_NAME}-${ANDROID_VERSION} Build for ${CODENAME} started!" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 
        else
            echo "Build for ${CODENAME} started!"
        fi
        make ${BACON_NAME}
        BUILD_STATUS=${?}
        if [ "${BUILD_STATUS}" != 0 ]; then
	        END_BUILD=$(date +"%s")
	        DIFF_BUILD=$((END_BUILD-START_BUILD))
            if [ "${TG_CHAT}" != "" ]; then
	            curl -s --data parse_mode=HTML --data text="Build for ${CODENAME} failed in $((DIFF_BUILD / 3600)) hours, $((DIFF_BUILD % 3600 / 60)) minutes and $((DIFF_BUILD % 60)) seconds!
"${TG_USERNAME}" don't be lazy and open build machine for errors" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 
                curl -s --data parse_mode=HTML --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendSticker
            else
                echo "Build for ${CODENAME} failed."
            fi
            return 1
        else
            END_BUILD=$(date +"%s")
	        DIFF_BUILD=$((END_BUILD-START_BUILD))
            if [ "${TG_CHAT}" != "" ]; then
                curl -s --data parse_mode=HTML --data text="${ROM_NAME} for ${CODENAME} succeed!
The build took $((DIFF_BUILD / 3600)) hours, $((DIFF_BUILD % 3600 / 60)) minutes and $((DIFF_BUILD % 60)) seconds!" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 
            else
                echo "${ROM_NAME} for ${CODENAME} succeed!"
            fi
            cd "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}"/out/target/product/"${CODENAME}"
            ROM_ZIP=$(find -type f -name "*.zip" -exec stat -c '%Y %n' {} \; | sort -nr | awk 'NR==1,NR==1 {print $2 }') 
            ROM_ZIP=$(basename $ROM_ZIP)
            RECOVERY_IMG=$(ls recovery.img)
            ROM_HASH=$(ls "${ROM_NAME}"*.sha256sum)
            if ! [ "${ROM_HASH}" == "" ]; then
                ROM_HASH256=$(find -type f -name "*.sha256sum" -exec stat -c '%Y %n' {} \; | sort -nr | awk 'NR==1,NR==1 {print $2 }')
                ROM_HASH=$(basename $ROM_HASH256)
            else
                ROM_HASH5=$(find -type f -name "*.md5sum" -exec stat -c '%Y %n' {} \; | sort -nr | awk 'NR==1,NR==1 {print $2 }')
                ROM_HASH=$(basename $ROM_HASH5)
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
                curl -s --data parse_mode=HTML --data text="Starting to upload..." --data chat_id=$TG_CHAT --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 
                if ! [ "${UPLOAD_RECOVERY}" = "true" ]; then
                    gh release create "${GH_RELEASE}" -t "${GH_RELEASE}" "${ROM_ZIP}" "${ROM_HASH}" "${RECOVERY_IMG}"
                    rm "${RECOVERY_IMG}"
                else 
                    gh release create "${GH_RELEASE}" -t "${GH_RELEASE}" "${ROM_ZIP}" "${ROM_HASH}"
                fi
                if [ "${TG_CHAT}" != "" ]; then
                    curl -s --data parse_mode=HTML --data text="Upload ${ROM_ZIP} for ${CODENAME} succeed!" --data reply_markup="{\"inline_keyboard\": [[{\"text\":\"Download!\", \"url\": \"https://github.com/${GH_USERNAME}/${GH_REPO}/${GH_RELEASE}\"}]]}" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage
                    curl -s --data parse_mode=HTML --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendSticker
                else
                    echo "Upload ${ROM_ZIP} for ${CODENAME} succeed! https://github.com/${GH_USERNAME}/${GH_REPO}/${GH_RELEASE}"
                fi
            fi

            #if sourceforge release
            if [ "${UPLOAD_TYPE}" == "SF" ]; then
                curl -s --data parse_mode=HTML --data text="Starting to upload..." --data chat_id=$TG_CHAT --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage 
			    sshpass -p "${SF_PASS}" scp ${ROM_ZIP} ${SF_USER}@frs.sourceforge.net:/home/frs/project/${SF_PROJECT}/${CODENAME}
                sshpass -p "${SF_PASS}" scp ${ROM_HASH} ${SF_USER}@frs.sourceforge.net:/home/frs/project/${SF_PROJECT}/${CODENAME}
                if [ "${UPLOAD_RECOVERY}" = "true" ]; then
                    sshpass -p "${SF_PASS}" scp ${RECOVERY_IMG} ${SF_USER}@frs.sourceforge.net:/home/frs/project/${SF_PROJECT}/${CODENAME}
                fi
                if [ "${TG_CHAT}" != "" ]; then
			        curl -s --data parse_mode=HTML --data text="Upload ${ROM_ZIP} for ${CODENAME} succeed!" --data reply_markup="{\"inline_keyboard\": [[{\"text\":\"Download!\", \"url\": \"https://sourceforge.net/p/${SF_PROJECT}/files/${CODENAME}/\"}]]}" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage
                    curl -s --data parse_mode=HTML --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendSticker
                else
                    echo "Upload ${ROM_ZIP} for ${CODENAME} succeed! https://sourceforge.net/p/${SF_PROJECT}/files/${CODENAME}/"
                fi
            fi

            #if google drive
            if [ "${UPLOAD_TYPE}" == "GD" ]; then
                GD_RELEASE="${BUILD_TYPE}"-"${ROM_ZIP}"
                GD_FOLDER="${MY_DIR}"/gd
                if ! [ -d "${GD_FOLDER}" ]; then
                    mkdir "${GD_FOLDER}"
                fi
                cp "${ROM_ZIP}" "${GD_FOLDER}"
                cp "${ROM_HASH}" "${GD_FOLDER}"
                if [ "${UPLOAD_RECOVERY}" = "true" ]; then
                    cp "${RECOVERY_IMG}" "${GDRIVE_FOLDER}"
                fi
                cd "${GD_FOLDER}"
                ./"${GD_FOLDER}"/gdrive upload "${ROM_ZIP}" --parent ${GD_PATH} --share --delete
                ./"${GD_FOLDER}"/gdrive upload "${ROM_HASH}" --parent ${GD_PATH} --share --delete
                if [ "${UPLOAD_RECOVERY}" = "true" ]; then
                    ./"${GD_FOLDER}"/gdrive upload "${RECOVERY_IMG}" --parent ${GD_PATH} --share --delete
                fi
                if [ "${TG_CHAT}" != "" ]; then
                    curl -s --data parse_mode=HTML --data text="Upload ${ROM_ZIP} for ${CODENAME} succeed!" --data reply_markup="{\"inline_keyboard\": [[{\"text\":\"Download!\", \"url\": \"https://drive.google.com/drive/folders/${GD_PATH}\"}]]}" --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage
                    curl -s --data parse_mode=HTML --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --data chat_id="${TG_CHAT}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendSticker
                else
                    echo "Upload ${ROM_ZIP} for ${CODENAME} succeed! https://drive.google.com/drive/folders/${GD_PATH}"
                fi
            fi

            #if telegram
            if [ "${UPLOAD_TYPE}" == "TG" ]; then
                TG_RELEASE="${BUILD_TYPE}"-"${ROM_ZIP}"
                TG_FOLDER="${MY_DIR}"/tg
                if ! [ -d "${TG_FOLDER}" ]; then
                    mkdir "${TG_FOLDER}"
                fi
                cp "${ROM_ZIP}" "${TG_FOLDER}"
                if [ "${UPLOAD_RECOVERY}" = "true" ]; then
                    cp "${RECOVERY_IMG}" "${TG_FOLDER}"
                fi
                cd ${TG_FOLDER}
                curl -F document=@"${ROM_ZIP}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendDocument?chat_id="${TG_CHAT}"
                if [ "${UPLOAD_RECOVERY}" = "true" ]; then
                    curl -F document=@"${ROM_ZIP}" --request POST https://api.telegram.org/bot"${TG_TOKEN}"/sendDocument?chat_id="${TG_CHAT}"
                    rm ${RECOVERY_IMG}
                fi
                rm "${ROM_ZIP}"
            fi
            cd "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}"
        fi
    done
}

## Start
if ! [ -d "${MY_DIR}"/rom/"${ROM_NAME}"-"${ANDROID_VERSION}/bootable" ]; then
    sync
fi
build
cd "${MY_DIR}"
