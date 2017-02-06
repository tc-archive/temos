#!/bin/bash

MASTER_IMAGE=jenkins-master
DATA_IMAGE=jenkins-data
NGINX_IMAGE=jenkins-nginx

docker build -t temos-${DATA_IMAGE}   ./${DATA_IMAFE}
docker build -t temos-${MASTER_IMAGE} ./${MASTER_IMAGE}
docker build -t temos-${NGINX_IMAGE}  ./${NGINX_IMAGE}
