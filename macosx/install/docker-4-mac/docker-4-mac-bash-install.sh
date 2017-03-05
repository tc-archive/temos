#!/bin/bash

# download latest 'docker for mac' image
curl https://download.docker.com/mac/stable/Docker.dmg -o Docker.dmg

# mount the image and copy it to the Applications folder
hdiutil mount Docker.dmg
pushd /Volumes/Docker
cp Docker.app ./Applications
popd

# remove the image
hdiutil unmount /Volumes/Docker
rm Docker.dmg
