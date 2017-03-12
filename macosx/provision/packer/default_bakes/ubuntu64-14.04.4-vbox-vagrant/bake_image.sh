#!/bin/bash -e

#export PACKER_LOG=1
rm packer_virtualbox-iso_virtualbox.box || true
packer build  -force -only virtualbox-iso packer.json
vagrant box remove vagrant_machine || true
vagrant box add vagrant_machine packer_virtualbox-iso_virtualbox.box
