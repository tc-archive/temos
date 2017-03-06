#!/bin/bash

VERSION="v1.1.0"
NAME="oracle-bmcs-python-sdk"
GITHUB_URL="https://github.com/oracle/bmcs-python-sdk/releases/download/${VERSION}/${NAME}.zip"
TARGET_DIR="."

# download sdk resources
CMD="curl -sLo ${TARGET_DIR}/${NAME}.zip ${GITHUB_URL}"
echo "downloading sdk: ${CMD}"
eval "${CMD}"

# unzip sdk resources
pushd ${TARGET_DIR}
unzip ${NAME}.zip

# create virtual environment
VIRTUAL_ENV_DIR="venv"
PYTHON_PATH="/usr/local/bin/python"
virtualenv -p ${PYTHON_PATH} ${VIRTUAL_ENV_DIR}
source ./venv/bin/activate
printf "Enabled virtual environment %s. Type 'deactivate' to exit." VIRTUAL_ENV_DIR

# install sdk client library
pushd ${NAME}
pip install oraclebmc-*-py2.py3-none-any.whl
popd

# tidy resources
rm -f ${NAME}.zip
rm -Rf ${TARGET_DIR}/${NAME} 

# check ssl verison on macosx
echo "python ssl version: " $(python -c "import ssl; print(ssl.OPENSSL_VERSION)")
