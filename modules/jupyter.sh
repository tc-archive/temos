#!/bin/bash

# https://github.com/jupyter/docker-stacks

source ${TEMOS_HOME}/macosx/scripts/core.sh
source ${TEMOS_HOME}/macosx/scripts/docker.sh

STACK=${1:-scipy-notebook}
NAME=temos-${STACK}
LOCALHOST_PORT=32768
CONTAINER_PORT=8888
LOCALHOST_MOUNT=${TEMOS_HOME}/notebooks
CONTAINER_MOUNT=/home/jovyan/work

# supported notebook stacks
_notebook_stacks=(
	"base-notebook"
	"minimal-notebook"
	"scipy-notebook"
	"r-notebook"
	"tensorflow-notebook"
	"datascience-notebook"
	"pyspark-notebook"
	"all-spark-notebook"
	)

# list the available notebook types
function _temos_jupyter_stacks() {
    printf "jupyter notebook stacks\n+\n"
    local IFS=" "
    for _notebook_stack in "${_notebook_stacks[@]}"
    do
        printf "|--- %-15s\n" ${_notebook_stack}
    done
    printf "\n"
}

# start a new jupyter container with the notebook data safely mounted
function _temos_jupyter_start() {
	local jupyter_exists=$(_temos_docker_container_exists "${NAME}")
	local jupyter_running=$(_temos_docker_container_running "${NAME}")
    if [[ ! -z "${jupyter_exists}" && -z "${jupyter_running}" ]]; then
		# if a jupyter container exists, but, is not running then start it...
        local start_cmd="docker start ${NAME}"
        eval "${start_cmd}"
	elif [[ -z "${jupyter_exists}" ]]; then
		# if no jupyter container exists then start one...
		local run_cmd="docker run -d \
			-p ${LOCALHOST_PORT}:${CONTAINER_PORT} \
			-v ${LOCALHOST_MOUNT}:${CONTAINER_MOUNT} \
			--name ${NAME} \
			jupyter/${STACK}"
        eval "${run_cmd}"
	fi
    _temos_docker_container_waitfor "${NAME}"
    sleep 1
}

# force remove the container (the notebook data should already be safely mounted)
function _temos_jupyter_stop() {
	docker rm -f ${NAME}
	if [[ ! -z $(_temos_has_alias temos-jupyter-ipython) ]]; then
    	unalias temos-ipython
	fi
}

# list all running jupyter servers along with access credentials
function _temos_jupyter_list() {
    docker exec -it ${NAME} jupyter notebook list \
        | sed 's/'"${CONTAINER_PORT}"'/'"${LOCALHOST_PORT}"'/g'
}

# open the jupyter viewer in a browser
function _temos_jupyter_open() {
    local url=`docker exec -it ${NAME} jupyter notebook list \
        | grep '\?token\=' \
        | awk -F'::' '{print $1}' \
        | sed 's/'"${CONTAINER_PORT}"'/'"${LOCALHOST_PORT}"'/g' \
        | sed 's/ //g'`
    echo "local data mount: ${LOCALHOST_MOUNT}"
    echo "open browser at : ${url}"  && curl ${url}
    open ${url}
}

alias temos-jupyter-stacks="_temos_jupyter_stacks"
alias temos-jupyter-start="_temos_jupyter_start"
alias temos-jupyter-stop="_temos_jupyter_stop"
alias temos-jupyter-list="_temos_jupyter_list"
alias temos-jupyter-open="_temos_jupyter_start && _temos_jupyter_open"
alias temos-jupyter-ipython="docker exec -it ${NAME} ipython"

