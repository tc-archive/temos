#!/bin/bash

# [home] https://github.com/oracle/terraform-provider-baremetal
# [download] https://github.com/oracle/terraform-provider-baremetal/releases

curl -sLO https://github.com/oracle/terraform-provider-baremetal/releases/download/v1.0.3/darwin.tar.gz

tar -zxvf darwin.tar.gz

rm -f darwin.tar.gz

#mv darwin_386/terraform-provider-baremetal ~/TemOS/bin
mv darwin_amd64/terraform-provider-baremetal ~/TemOS/bin

touch ~/.terraformrc
cat > ~/.terraformrc << EOF
providers {
  baremetal = ~/TemOS/bin/terraform-provider-baremetal
}
EOF

# export codes - add to bash rc? separate env.sh file?
#
# export TF_VAR_tenancy_ocid=
#export TF_VAR_user_ocid=
#export TF_VAR_fingerprint=
#export TF_VAR_private_key_path=<fully qualified path>
#export TF_VAR_private_key_password=

curl -sLO https://github.com/oracle/terraform-provider-baremetal/blob/master/docs/examples/network/simple_vcn/vcn.tf
