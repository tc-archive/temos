#!/bin/bash

# start a local coreos vagrant cluster
TEMOS_HOME=~/TemOS
INSTALL_HOME=${TEMOS_HOME}/vagrant/coreos-vagrant-cluster

# configure fleetctl to point to the cluster
export FLEETCTL_TUNNEL=127.0.0.1:2222

# stop the nginx service via fleet
fleetctl stop  nginx.service

# stop and destroy the cluster
source ${INSTALL_HOME}/coreos-vagrant-cluster-stop.sh
source ${INSTALL_HOME}/coreos-vagrant-cluster-destroy.sh

