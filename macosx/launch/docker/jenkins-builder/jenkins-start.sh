#!/bin/bash

# https://hub.docker.com/_/jenkins/ 

source ${TEMOS_HOME}/macosx/init.sh

DATA_IMAGE_NAME=temos-jenkins-data
DATA_CONTAINER_NAME=${DATA_IMAGE_NAME}
# DATA_CONTAINER_MOUNT=/var/jenkins_home
# DATA_LOCALHOST_MOUNT=${TEMOS_HOME}/data/jenkins
# DATA_LOCALHOST_VOLUME=${DATA_IMAGE_NAME}

JENKINS_IMAGE_NAME=temos-jenkins-master
JENKINS_CONTAINER_NAME=${JENKINS_IMAGE_NAME}
UI_CONTAINER_PORT=8080
UI_LOCALHOST_PORT=8080
SLAVE_AGENT_CONTAINER_PORT=50000
SLAVE_AGENT_LOCALHOST_PORT=50000

NGINX_IMAGE_NAME=temos-jenkins-nginx
NGINX_CONTAINER_NAME=${NGINX_IMAGE_NAME}
NGINX_CONTAINER_PORT=80
NGINX_LOCALHOST_PORT=80

# data volume container
#
docker run -d \
    --name=${DATA_CONTAINER_NAME} \
    ${DATA_IMAGE_NAME}

# jekins container
#
#    --env JENKINS_OPTS="--handlerCountStartup=100 --handlerCountMax=300" \
docker run -d \
    -p ${UI_LOCALHOST_PORT}:${UI_CONTAINER_PORT} \
    -p ${SLAVE_AGENT_LOCALHOST_PORT}:${SLAVE_AGENT_CONTAINER_PORT} \
    --volumes-from=${DATA_CONTAINER_NAME} \
    --env JAVA_OPTS="-Xmx8192m" \
    --name ${JENKINS_CONTAINER_NAME} \
    ${JENKINS_IMAGE_NAME}

# rginx container
#
docker run -d \
    -p ${NGINX_LOCALHOST_PORT}:${NGINX_CONTAINER_PORT} \
    --name=${NGINX_CONTAINER_NAME} \
    --link ${JENKINS_CONTAINER_NAME}:${JENKINS_CONTAINER_NAME} \
    ${NGINX_CONTAINER_NAME}

# backup jenkins data
# cp $ID:/var/jenkins_home


URL=http://localhost:${UI_LOCALHOST_PORT}
curl -I -m 60 ${URL}/login

PASSWORD_CMD="docker exec ${JENKINS_CONTAINER_NAME} cat /var/jenkins_home/secrets/initialAdminPassword"
# echo "PASSWORD_CMD: ${PASSWORD_CMD}"
PASSWORD=`${PASSWORD_CMD}`
echo "PASWORD: ${PASSWORD}"

# CRUMB=`curl -s -u admin:${PASSWORD} ${URL}/crumbIssuer/api/json | jq -r ".crumb"`
# echo "CRUMB  : ${CRUMB}"
#
# curl -i \
#     -H "Accept: application/json" \
#     -X POST -d "from":"/", "j_username":"admin","j_password":"${PASSWORD}","Jenkins-Crumb:":"${CRUMB}" \
#     ${URL}/j_acegi_security_check

# open browser
open ${URL}

# check container java process
# docker exec ${CONTAINER_NAME} ps -ef | grep java

# tail jenkins logs
# docker exec ${CONTAINER_NAME} tail -f /var/log/jenkins/jenkins.log

# copy logs
# docker cp ${CONTAINER_NAME}:/var/log/jenkins/jenkins.log jenkins.log
