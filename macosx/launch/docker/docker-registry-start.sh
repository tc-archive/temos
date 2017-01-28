#!/bin/bash

NAME=temos-registry

RUNNING=$(docker ps | grep "${NAME}" | awk -F " " '{print $NF}')
STOPPED=$(docker ps -a | grep "${NAME}" | awk -F " " '{print $NF}')

if [[ ${RUNNING} == ${NAME} ]]; then
    echo "container ${NAME} already running, continuing..."
elif [[ ${STOPPED} == ${NAME} ]]; then
    echo "container ${NAME} stopped, restarting..."
    docker start ${NAME}
else
    echo "running container ${NAME}"
    docker run -d -p 5000:5000 --name ${NAME} registry:2
fi


