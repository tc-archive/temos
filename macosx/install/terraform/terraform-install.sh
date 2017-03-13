#!/bin/bash

# [home] https://www.terraform.io/
# [download] https://www.terraform.io/downloads.html

MODULE="terraform"
VERSION="0.8.8"
NAME="terraform_0.8.8_darwin_amd64"
BASE_URL="https://releases.hashicorp.com/terraform"
TARGET_DIR="${TEMOS_HOME}/bin"

# navigate to target
mkdir -p ${TARGET_DIR}
pushd ${TARGET_DIR}

# download sdk resources
TARGET_URL="${BASE_URL}/${VERSION}/${NAME}.zip"
CMD="curl -sLo ${TARGET_DIR}/${NAME}.zip ${TARGET_URL}"
echo "downloading ${MODULE}: ${CMD}"
eval "${CMD}"

# unzip sdk resources
unzip ${NAME}.zip
rm ${NAME}.zip
mv terraform ${TARGET_DIR}

popd
