#!/bin/bash

# https://github.com/jupyter/docker-stacks

# --- supported stacks ---
#
# base-notebook
# minimal-notebook
# scipy-notebook
# r-notebook
# tensorflow-notebook
# datascience-notebook
# pyspark-notebook
# all-spark-notebook

TEMOS_HOME=~/Temos

STACK=scipy-notebook
NAME=temos-${STACK}
LOCALHOST_PORT=32768
CONTAINER_PORT=8888
LOCALHOST_MOUNT=${TEMOS_HOME}/notebooks
CONTAINER_MOUNT=/home/jovyan/work

docker run -d \
    -p ${LOCALHOST_PORT}:${CONTAINER_PORT} \
    -v ${LOCALHOST_MOUNT}:${CONTAINER_MOUNT} \
    --name ${NAME} \
    jupyter/${STACK}

echo "listing servers..."
docker exec -it ${NAME} jupyter notebook list \
    | sed 's/'"${CONTAINER_PORT}"'/'"${LOCALHOST_PORT}"'/g'

URL=`docker exec -it ${NAME} jupyter notebook list \
    | grep '\?token\=' \
    | awk -F'::' '{print $1}' \
    | sed 's/'"${CONTAINER_PORT}"'/'"${LOCALHOST_PORT}"'/g' \
    | sed 's/ //g'`

echo "server url      : ${URL}" && curl ${URL}
echo "local data mount: ${LOCALHOST_MOUNT}"

alias temos-ipython="docker exec -it ${NAME} ipython"

# TODO check for OS type
echo "open browser at : ${URL}" 
open ${URL}

