#!/bin/bash

# [home] https://www.terraform.io/
# [download] https://www.terraform.io/downloads.html

curl -O https://releases.hashicorp.com/terraform/0.8.8/terraform_0.8.8_darwin_amd64.zip?_ga=1.33552318.1236805785.1477664760

unzip terraform_0.8.8_darwin_amd64.zip

chmod u+wrx terraform

mv terraform ~/TemOS/bin


