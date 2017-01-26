#!/bin/bash

# start a local coreos vagrant cluster
TEMOS_HOME=~/TemOS
INSTALL_HOME=${TEMOS_HOME}/macosx/provision/virtual/vagrant/coreos-fleet-vagrant-cluster
source ${INSTALL_HOME}/coreos-vagrant-cluster-create.sh
source ${INSTALL_HOME}/coreos-vagrant-cluster-start.sh

# configure fleetctl to point to the cluster
export FLEETCTL_TUNNEL=127.0.0.1:2222

# start the nginx service via fleet
fleetctl start nginx.service
