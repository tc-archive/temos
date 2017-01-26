#!/bin/bash

# simple test of local docker registry

IMAGE_NAME=alpine
TEST_IMAGE_NAME=temos-${IMAGE_NAME}

# start the registry if not already started
# ./docker-start-docker-registry.sh

# clean docker image cache
docker rmi ${IMAGE_NAME}
docker rmi localhost:5000/${TEST_IMAGE_NAME}

# test the registry: pul remotel, tag, push local, pull local
docker pull ${IMAGE_NAME} 
docker tag ${IMAGE_NAME} localhost:5000/${TEST_IMAGE_NAME}
docker push localhost:5000/${TEST_IMAGE_NAME}
docker rmi localhost:5000/${TEST_IMAGE_NAME}
docker pull localhost:5000/${TEST_IMAGE_NAME}

# clean docker image cache
docker rmi ${IMAGE_NAME}
docker rmi localhost:5000/${TEST_IMAGE_NAME}
# docker stop temos-registry && docker rm -v temos-registry
