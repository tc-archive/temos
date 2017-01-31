#!/bin/bash

MASTER_IMAGE=jenkins-master
DATA_IMAGE=jenkins-data
NGINX_IMAGE=jenkins-nginx

docker build -t temos-${DATA_IMAGE}   ./jenkins-data
docker build -t temos-${MASTER_IMAGE} ./jenkins-master
docker build -t temos-${NGINX_IMAGE}  ./jenkins-nginx
