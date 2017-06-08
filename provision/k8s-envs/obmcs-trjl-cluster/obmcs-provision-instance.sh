#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "Error: Invalid arguments"
    echo "    Usage: ./bmcs-launch.sh <NAME>"
    exit 1
fi

# pushd /Users/tlang/Temos/oraclebmc-cli
# . venv/bin/activate
# popd

source ./obmcs-provision-instance-env.sh

NAME=$1
bmcs compute instance launch \
    --display-name=${NAME} \
    --compartment-id=${COMPARTMENT}\
    --availability-domain=${AD} \
    --image-id=${IMAGE} \
    --shape=${SHAPE} \
    --subnet-id=${SUBNET} \
    --ssh-authorized-keys-file=${PUBLIC_KEY_FILE}
