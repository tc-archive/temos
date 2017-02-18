#!/bin/bash

# docker
#
alias docker-clean='unset ${!DOCKER_*}'
alias moby='screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty'

# Delete all exited docker containers. Optionally, pass in a grep expression to target 
# specific containers. e.g. 'clean-exited-containers temos', 'clean-exited-containers temos'.
#
function clean-exited-containers() {
    local _targets=$@
    local _cmd="docker ps --filter \"status=exited\" | awk 'NR>1 {print \$1}'"
    if [[ ! -z "${_targets}" ]]; then
        _cmd="docker ps --filter \"status=exited\" | grep '${_targets}' | awk '{print \$1}'"
    fi
    local _to_delete=$(eval ${_cmd})
    if [[ ! -z "${_to_delete}" ]]; then
        echo "${_to_delete}" | xargs docker rm
    fi
}
alias docker-container-clean="clean-exited-containers"

# docker machine
#
# alias docker-init-default='eval "$(docker-machine env default)"'
# alias docker-init-local='eval "$(docker-machine env local)"'
# alias create-default="docker-machine create --driver virtualbox default"
# alias kitematic="open '/Applications/Docker/Kitematic (Beta).app'"
