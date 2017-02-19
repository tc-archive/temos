#!/bin/bash

#---------------------------------------------------------------------------------------------------
# docker
#
alias temos_docker_clean='unset ${!DOCKER_*}'
alias temos_docker_moby='screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty'

#---------------------------------------------------------------------------------------------------
# Delete all exited docker containers. Optionally, pass in a grep expression to target 
# specific containers. e.g. 'clean-exited-containers temos', 'clean-exited-containers temos'.
#
function temos_docker_container_clean_exited() {
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
alias docker_container_clean="clean-exited-containers"

#---------------------------------------------------------------------------------------------------
# Function to return the name of the docker container if it exists; else nothing.
#
function temos_docker_container_exists() {
    local _container_name=$1
    if [[ ! -z "${_container_name}" ]]; then
        local _has_container_name=$(docker ps -a | awk 'NR>1 {print $NF}' | grep "${_container_name}")
    fi
    echo "${_has_container_name}"
}

#---------------------------------------------------------------------------------------------------
# Function to return the name of the RUNNING docker container if it exists; else nothing.
#
function temos_docker_container_running() {
    local _container_name=$1
    if [[ ! -z "${_container_name}" ]]; then
        local _has_container_name=$(docker ps | awk 'NR>1 {print $NF}' | grep "${_container_name}")
    fi
    echo "${_has_container_name}"
}

# docker machine
#
# alias docker-init-default='eval "$(docker-machine env default)"'
# alias docker-init-local='eval "$(docker-machine env local)"'
# alias create-default="docker-machine create --driver virtualbox default"
# alias kitematic="open '/Applications/Docker/Kitematic (Beta).app'"
