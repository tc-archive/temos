#!/bin/bash

HOME_PAGE=https://hyper.is/
DOWNLOAD_SERVER=https://hyper-updates.now.sh/download/mac
DMG_NAME=hyper.dmg
NAME=hyper

# dowload the osx installer
echo "downloading ${DMG_NAME} from: ${URL}"
URL=${DOWNLOAD_SERVER}
curl ${URL} -o ${DMG_NAME}

# mount the downloaded installer
echo "mounting ${DMG_NAME} ..."
hdiutil mount ${DMG_NAME}
DMG_SRC_DIR=/Volumes/`ls -l /Volumes | grep -e 'Hyper' | sed 's/^.*Hyper/Hyper/g'`
LOCAL_DEST_DIR="/Volumes/Macintosh HD"

echo "installing ${NAME} ..."
cp -Rf "${DMG_SRC_DIR}/${NAME}.app" "${DMG_SRC_DIR}/Applications"

echo "unmounting ${DMG_SRC_DIR} ..."
hdiutil unmount "${DMG_SRC_DIR}"

echo "removing download ./${DMG_NAME} ..."
rm ./${DMG_NAME}

