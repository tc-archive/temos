#!/bin/bash

REPO_URL=https://github.com/AllenDowney
REPO_NAME=ThinkDSP

INSTALL_PATH="${1-.}"
INSTALL_NAME="${2-ThinkDSP}"

git clone ${REPO_URL}/${REPO_NAME}.git ${INSTALL_PATH}/${INSTALL_NAME}
