#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME_DIR=coreos-vagrant-cluster-runtime

# remove the local cluster folder 
rm -Rf ${HOME_DIR}
