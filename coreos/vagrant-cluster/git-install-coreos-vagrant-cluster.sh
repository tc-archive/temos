#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME_DIR=coreos-vagrant-cluster-runtime
# $instance_name_prefix
PRIMARY_INSTANCE=core-01

git clone https://github.com/coreos/coreos-vagrant.git ${HOME_DIR}

mv ${HOME_DIR}/Vagrantfile           ${HOME_DIR}/Vagrantfile.sample
cp ${SCRIPT_DIR}/default-Vagrantfile ${HOME_DIR}/Vagrantfile
cp ${SCRIPT_DIR}/default-user-data   ${HOME_DIR}/user-data
cp ${SCRIPT_DIR}/default-config.rb   ${HOME_DIR}/config.rb

# add private key to ssh-agent
ssh-add ~/.vagrant.d/insecure_private_key

# no ssh-agent
# vagrant ssh-config core-01 >> ~/.ssh/config

pushd ${HOME_DIR}

vagrant up

SSH_PORT=$(vagrant port ${PRIMARY_INSTANCE}| grep '22 (guest) =>' | cut -d' ' -f 8)
echo Vagrant ${PRIMARY_INSTANCE} ssh port mapped to: $SSH_PORT

export FLEETCTL_TUNNEL=127.0.0.1:$SSH_PORT

popd
