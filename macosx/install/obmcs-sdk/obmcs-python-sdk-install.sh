#!/bin/bash

VERSION="v1.1.0"
NAME="oracle-bmcs-python-sdk"
GITHUB_URL="https://github.com/oracle/bmcs-python-sdk/releases/download/${VERSION}/${NAME}.zip"
TARGET_DIR="."

CMD="curl -sLo ${TARGET_DIR}/${NAME}.zip ${GITHUB_URL}"
echo "downloading sdk: ${CMD}"
eval "${CMD}"
unzip ${NAME}.zip
rm ${NAME}.zip

VIRTUAL_ENV_DIR="venv"
PYTHON_PATH="/usr/local/bin/python"
# create virtual environment
virtualenv -p ${PYTHON_PATH} ${VIRTUAL_ENV_DIR}
source ./venv/bin/activate
# deactivate

# install library
pushd ${NAME}
pip install oraclebmc-*-py2.py3-none-any.whl
popd



# check ssl verison on macosx

# python -c "import ssl; print(ssl.OPENSSL_VERSION)"
echo "python ssl version: " $(python -c "import ssl; print(ssl.OPENSSL_VERSION)")
# brew update
# brew install openssl
# brew install pythonbrew install python
