#!/bin/bash


https://github.com/GoogleCloudPlatform/spinnaker-deploymentmanager.git

gcloud deployment-manager deployments create --config config.jinja [DEPLOYMENT_NAME] --properties jenkinsPassword=[YOUR_PASSWORD]

gcloud compute instances list | grep spinnaker

gcloud compute ssh [DEPLOYMENT_NAME]-spinnaker-ogo8 --zone us-west1-a -- -L 9000:localhost:9000 -L8084:localhost:8084

gcloud deployment-manager deployments delete [DEPLOYMENT_NAME]

open http://localhost:9000


