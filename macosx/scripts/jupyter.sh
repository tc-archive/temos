#!/bin/bash

# https://github.com/jupyter/docker-stacks

source ./core.sh
source ./docker.sh

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
function temos__jupyter_stacks() {
    printf "jupyter notebook stacks\n+\n"
    local IFS=" "
    for _notebook_stack in "${_notebook_stacks[@]}"
    do
        printf "|--- %-15s\n" ${_notebook_stack}
    done
    printf "\n"
}

# start a new jupyter container with the notebook data safely mounted
function temos__jupyter_start() {
	local _jupyter_exists=$(temos::docker-container-exists "${NAME}")
	local _jupyter_running=$(temos::docker-container-running "${NAME}")
    if [[ ! -z "${_jupyter_exists}" && -z "${_jupyter_running}" ]]; then
		# if a jupyter container exists, but, is not running then start it...
        local _start_cmd="docker start ${NAME}"
        eval "${_start_cmd}"
	elif [[ -z "${_jupyter_exists}" ]]; then
		# if no jupyter container exists then start one...
		local _run_cmd="docker run -d \
			-p ${LOCALHOST_PORT}:${CONTAINER_PORT} \
			-v ${LOCALHOST_MOUNT}:${CONTAINER_MOUNT} \
			--name ${NAME} \
			jupyter/${STACK}"
        eval "${_run_cmd}"
	fi
    temos__docker_container_waitfor "${NAME}"
    sleep 1
}

# force remove the container (the notebook data should already be safely mounted)
function temos__jupyter_stop() {
	docker rm -f ${NAME}
	if [[ ! -z $(has_alias temos-jupyter-ipython) ]]; then
    	unalias temos-ipython
	fi
}

# list all running jupyter servers along with access credentials
function temos__jupyter_list() {
    docker exec -it ${NAME} jupyter notebook list \
        | sed 's/'"${CONTAINER_PORT}"'/'"${LOCALHOST_PORT}"'/g'
}

# open the jupyter viewer in a browser
function temos__jupyter_open() {
    local _url=`docker exec -it ${NAME} jupyter notebook list \
        | grep '\?token\=' \
        | awk -F'::' '{print $1}' \
        | sed 's/'"${CONTAINER_PORT}"'/'"${LOCALHOST_PORT}"'/g' \
        | sed 's/ //g'`
    echo "local data mount: ${LOCALHOST_MOUNT}"
    echo "open browser at : ${_url}"  && curl ${_url}
    open ${_url}
}

alias temos-jupyter-stacks="temos__jupyter_stacks"
alias temos-jupyter-start="temos__jupyter_start"
alias temos-jupyter-stop="temos__jupyter_stop"
alias temos-jupyter-list="temos__jupyter_list"
alias temos-jupyter-open="temos__jupyter_start && temos__jupyter_open"
alias temos-jupyter-ipython="docker exec -it ${NAME} ipython"

