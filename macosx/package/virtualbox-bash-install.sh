#!/bin/bash

DOWNLOAD_SERVER=http://download.virtualbox.org/virtualbox
echo Searching for new versions   : ${DOWNLOAD_SERVER}
# grep the version main dowload page hrefs to get the highest version
VERSION=`curl -s ${DOWNLOAD_SERVER} \
    | sed -n 's/.*href="\([^"]*\).*/\1/p' \
    | sort -n \
    | tail -n 1 \
    | sed "s/.$//g"`
echo Found latest version number  : ${VERSION}
# grep that versions download page to get the osx installer
NAME=`curl -s  ${DOWNLOAD_SERVER}/${VERSION}/ \
    | sed -n 's/.*href="\([^"]*\).*/\1/p' \
    | grep 'OSX.dmg'`
echo Found latest version         : ${NAME}

# dowload the osx installer
echo "downloading ${NAME} from: ${URL}"
URL=${DOWNLOAD_SERVER}/${VERSION}/${NAME}
curl ${URL} -o ${NAME}

# mount the downloaded installer
echo "mounting ${NAME} ..."
hdiutil mount ${NAME}

echo "installing ${NAME} ..."
pushd /Volumes/VirtualBox
sudo installer -package /Volumes/VirtualBox/VirtualBox.pkg -target "/Volumes/Macintosh HD"
cp UserManual.pdf ./Applications/VirtualBox-UserManual.pdf
cp VirtualBox_Uninstall.tool ./Applications
popd

echo "unmounting ${NAME} ..."
hdiutil unmount /Volumes/VirtualBox

echo "removing download ./${NAME} ..."
rm ./${NAME}

