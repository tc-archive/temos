#!/bin/bash

source ./secret-env.sh

export KUBECONFIG=`pwd`/admin.conf

alias ssh-kube-master="ssh -i ${PRIVATE_KEY} ${USER}@${PUBLIC_IP_MASTER_NODE}"
alias ssh-kube-01="ssh -i ${PRIVATE_KEY} ${USER}@${PUBLIC_IP_NODE_01}"
alias ssh-kube-02="ssh -i ${PRIVATE_KEY} ${USER}@${PUBLIC_IP_NODE_02}" 

alias get-cluster-kubeconfig="scp -i ${PRIVATE_KEY} ${USER}@${PUBLIC_IP_MASTER_NODE}:admin.conf ${KUBECONFIG} ."

alias kube-proxy="kubectl proxy"
