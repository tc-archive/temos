#!/bin/bash

# [home] https://github.com/oracle/terraform-provider-baremetal
# [download] https://github.com/oracle/terraform-provider-baremetal/releases

MODULE="obmcs-terraform-plugin"
#VERSION="v1.0.3"
VERSION="v1.0.13"
NAME="terraform-provider-baremetal"
PACKAGE="tar.gz"
BASE_URL="https://github.com/oracle/terraform-provider-baremetal/releases/download"
TARGET_DIR="${TEMOS_HOME}/bin"

# navigate to target
mkdir -p ${TARGET_DIR}
pushd ${TARGET_DIR}

# download sdk resources
TARGET_URL="${BASE_URL}/${VERSION}/darwin.${PACKAGE}"
CMD="curl -sLo ${TARGET_DIR}/darwin.${PACKAGE} ${TARGET_URL}"
echo "downloading ${MODULE}: ${CMD}"
eval "${CMD}"

# unzip sdk resources
tar -zxvf "darwin.${PACKAGE}"
rm -f "darwin.${PACKAGE}"
mv darwin_amd64/terraform-provider-baremetal ${TARGET_DIR}
rm -Rf darwin_386 darwin_amd64 

popd

# generate a default configuration
TERRAFORM_CONFIG="${HOME}/.terraformrc" 
function _temos_generate_default_config() {
    echo  "config: ${TERRAFORM_CONFIG}" 
    touch "${TERRAFORM_CONFIG}"
    cat > "${TERRAFORM_CONFIG}" << EOF
providers {
    baremetal = ~/TemOS/bin/terraform-provider-baremetal
}
EOF
}
if [ ! -f ${TERRAFORM_CONFIG} ]; then
    _temos_generate_default_config
else
    printf "Configuration file already exists: %s\n" ${TERRAFORM_CONFIG}
fi

# export codes - add to bash rc? separate env.sh file?
#
# export TF_VAR_tenancy_ocid=
# export TF_VAR_user_ocid=
# export TF_VAR_fingerprint=
# export TF_VAR_private_key_path=<fully qualified path>
# export TF_VAR_private_key_password=

# dowload exmaple
#
# curl -sLO https://github.com/oracle/terraform-provider-baremetal/blob/master/docs/examples/network/simple_vcn/vcn.tf
