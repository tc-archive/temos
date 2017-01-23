#!/bin/bash

# default parameters
#
NUM_NODES=3
VM_MEMORY=1024
VM_CPUS=1

# process script paramters options
#
while [[ $# -gt 1 ]]
do
key="$1"
case $key in
    -n|--num_nodes)
    NUM_NODES="$2"
    shift # past argument
    ;;
    -m|--vm_memory)
    VM_MEMORY="$2"
    shift # past argument
    ;;
    -c|--vm_cpus)
    VM_CPUS="$2"
    shift # past argument
    ;;
    *)
     # unknown option
    ;;
esac
shift # past argument or value
done

# create cluster
#
echo create cluster...
echo NUM_NODES  = "${NUM_NODES}"
echo VM_MEMORY  = "${VM_MEMORY}"
echo VM_CPUS    = "${VM_CPUS}"

HOME_DIR=coreos-vagrant-${NUM_NODES}-node-cluster
if [ -d ${HOME_DIR} ]
then
    rm -Rf ${HOME_DIR}
fi

git clone https://github.com/coreos/coreos-vagrant.git ${HOME_DIR} 
pushd ${HOME_DIR}
cp user-data.sample user-data
cp config.rb.sample config.rb
sed -i -E 's/^$num_instances = [0-9]*$/$num_instances = '$NUM_NODES'/g' ./Vagrantfile
sed -i -E 's/^$vm_memory = [0-9]*$/$vm_memory = '$VM_MEMORY'/g' ./Vagrantfile
sed -i -E 's/^$vm_cpus = [0-9]*$/$vm_cpus = '$VM_CPUS'/g' ./Vagrantfile
sed -i -E 's/^$num_instances=[0-9]*$/$num_instances='$NUM_NODES'/g' ./config.rb
rm ./Vagrantfile-E
rm ./config.rb-E
popd

