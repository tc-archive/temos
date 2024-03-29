#!/bin/bash

#---------------------------------------------------------------------------------------------------
# docker
#
alias temos-docker-clean='unset ${!DOCKER_*}'
alias temos-docker-moby='screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty'

#---------------------------------------------------------------------------------------------------
# Delete all exited docker containers. Optionally, pass in a grep expression to target 
# specific containers. e.g. 'clean-exited-containers temos', 'clean-exited-containers temos'.
#
function _temos_docker_container_clean_exited() {
    local targets=$@
    local cmd="docker ps --filter \"status=exited\" | awk 'NR>1 {print \$1}'"
    if [[ ! -z "${_targets}" ]]; then
        cmd="docker ps --filter \"status=exited\" | grep '${targets}' | awk '{print \$1}'"
    fi
    local to_delete=$(eval ${cmd})
    if [[ ! -z "${to_delete}" ]]; then
        echo "${to_delete}" | xargs docker rm
    fi
}
alias docker-container-clean="temos__docker_container_clean_exited"

#---------------------------------------------------------------------------------------------------
# Function to return the name of the docker container if it exists; else nothing.
#
function _temos_docker_container_exists() {
    local container_name=$1
    if [[ ! -z "${container_name}" ]]; then
        local has_container_name=$(docker ps -a | awk 'NR>1 {print $NF}' | grep "${container_name}")
    fi
    echo "${has_container_name}"
}

#---------------------------------------------------------------------------------------------------
# Function to return the name of the RUNNING docker container if it exists; else nothing.
#
function _temos_docker_container_running() {
    local container_name=$1
    if [[ ! -z "${container_name}" ]]; then
        local has_container_name=$(docker ps | awk 'NR>1 {print $NF}' | grep "${container_name}")
    fi
    echo "${has_container_name}"
}

#---------------------------------------------------------------------------------------------------
# Function that will wait for the specified container to reacher a 'RUNNING' state.
# TODO: Add a timeout!
#
function _temos_docker_container_waitfor() {
    local container_name=$1
    if [[ ! -z "${container_name}" ]]; then
        until [ "`docker inspect -f {{.State.Running}} ${container_name}`" == "true" ]; do
            sleep 0.1;
        done
    fi
}

# docker machine
#
# alias docker-init-default='eval "$(docker-machine env default)"'
# alias docker-init-local='eval "$(docker-machine env local)"'
# alias create-default="docker-machine create --driver virtualbox default"
# alias kitematic="open '/Applications/Docker/Kitematic (Beta).app'"
