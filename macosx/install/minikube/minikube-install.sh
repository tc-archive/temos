#!/bin/bash

# install minikube
#
# https://github.com/kubernetes/minikube/releases
#

version=v0.19.1

# mac osx
curl -Lo minikube https://storage.googleapis.com/minikube/releases/${version}/minikube-darwin-amd64 \
	&& chmod +x minikube \
	&& sudo mv minikube /usr/local/bin/


