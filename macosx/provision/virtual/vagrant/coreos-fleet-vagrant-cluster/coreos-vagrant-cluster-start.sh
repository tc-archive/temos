#!/bin/bash

HOME_DIR=coreos-vagrant-cluster-runtime
# $instance_name_prefix
PRIMARY_INSTANCE=core-01

pushd ${HOME_DIR}

vagrant up

SSH_PORT=$(vagrant port ${PRIMARY_INSTANCE}| grep '22 (guest) =>' | cut -d' ' -f 8)
echo Vagrant ${PRIMARY_INSTANCE} ssh port mapped to: $SSH_PORT

export FLEETCTL_TUNNEL=127.0.0.1:$SSH_PORT

popd

