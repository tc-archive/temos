#!/bin/bash

python -V

URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-144.0.0-darwin-x86_64.tar.gz"

curl -O ${URL}

tar -xvf google-cloud-sdk-144.0.0-darwin-x86_64.tar.gz

chmod -R u+rwx google-cloud-sdk

pushd google-cloud-sdk

./install.sh



popd


# gcloud components install app-engine-go

source ~./bash_profile
gcloud init

# example to ssh onto running instance
#
# gcloud compute --project "trjl-158912" ssh --zone "us-central1-c" "mongodb-backend"

