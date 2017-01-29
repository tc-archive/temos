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

source ${TEMOS_HOME}/macosx/init.sh

STACK=${1:-scipy-notebook}
NAME=temos-${STACK}

docker rm -f ${NAME}

if [[ ! -z $(has_alias temos-ipython) ]]; then
    unalias temos-ipython
fi


