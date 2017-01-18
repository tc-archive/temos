#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME_DIR=coreos-vagrant-cluster-runtime

pushd ${HOME_DIR}

# destroy all vagrant instances bound to the cluster (determine by directory name)
vagrant global-status \
    | grep ${HOME_DIR} \
    | awk '{print $2}' \
    | xargs vagrant destroy -f

# ensure vagrant is left in a tidy state
vagrant global-status --prune

# remove any fleetctl ssh keys that were added...
sed -i .bu '/:2222/d' ~/.fleetctl/known_hosts

popd

# remove the local cluster folder 
rm -Rf ${HOME_DIR}
