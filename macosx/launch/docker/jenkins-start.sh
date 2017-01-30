#!/bin/bash

# https://hub.docker.com/_/jenkins/ 

source ${TEMOS_HOME}/macosx/init.sh

IMAGE_NAME=jenkins
CONTAINER_NAME=temos-${IMAGE_NAME}-master
UI_LOCALHOST_PORT=8080
UI_CONTAINER_PORT=8080
SLAVE_AGENT_LOCALHOST_PORT=50000
SLAVE_AGENT_CONTAINER_PORT=50000
LOCALHOST_MOUNT=${TEMOS_HOME}/data/jenkins
CONTAINER_MOUNT=/var/jenkins_home

docker run -d \
    -p ${UI_LOCALHOST_PORT}:${UI_CONTAINER_PORT} \
    -p ${SLAVE_AGENT_LOCALHOST_PORT}:${SLAVE_AGENT_CONTAINER_PORT} \
    -v ${LOCALHOST_MOUNT}:${CONTAINER_MOUNT} \
    --env JAVA_OPTS="-Xmx8192m" \
    --env JENKINS_OPTS="--handlerCountStartup=100 --handlerCountMax=300" \
    --name ${CONTAINER_NAME} \
    ${IMAGE_NAME}

# backup jenkins data
# cp $ID:/var/jenkins_home


URL=http://localhost:${UI_LOCALHOST_PORT}

PASSWORD=`docker exec temos-jenkins-master cat /var/jenkins_home/secrets/initialAdminPassword`
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
docker exec temos-jenkins-master ps -ef | grep java

# tail jenkins logs
docker exec temos-jenkins-master tail -f /var/log/jenkins/jenkins.log

# copy logs
docker cp temos-jenkins-master:/var/log/jenkins/jenkins.log jenkins.log
