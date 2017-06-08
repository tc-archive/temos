account=tim.langford@gmail.com
project=trjl-158912
zone_=europe-west1-c
username=tlangfor
ssh_key=${HOME}/.ssh/google_compute_engine

cluster_name=trjl-gce-k8s-cluster
machine_type=f1-micro
num_nodes=3

create-cluster:
	# https://cloud.google.com/sdk/gcloud/reference/auth/login
	gcloud auth login ${account}
	# https://cloud.google.com/sdk/gcloud/reference/container/clusters/create
	gcloud container clusters create ${cluster_name} --machine-type ${machine_type} --num-nodes ${num_nodes}
	# https://cloud.google.com/sdk/gcloud/reference/container/clusters/get-credentials
	gcloud container clusters get-credentials ${cluster_name}

destroy-cluster:
	# https://cloud.google.com/sdk/gcloud/reference/auth/login
	gcloud auth login ${account}
	# https://cloud.google.com/sdk/gcloud/reference/container/clusters/create
	gcloud container clusters delete ${cluster_name} --async

describe-cluster:
	# https://cloud.google.com/sdk/gcloud/reference/container/clusters/describe
	gcloud container clusters describe trjl-gce-k8s-cluster

configure-kubectl:
	# https://cloud.google.com/sdk/gcloud/reference/container/clusters/get-credentials
	gcloud container clusters get-credentials ${cluster_name} --project ${project} --zone ${zone}

use-cluster:
	kubectl config use-context gke_trjl-158912_europe-west1-c_trjl-gce-k8s-cluster

start-proxy:
	kubectl proxy

get-nodes:
	kubectl get nodes -o wide

ssh-node:
	ssh -i ${ssh-key} ${user_name}@${ip_address}

ssh-instance:
	gcloud compute ssh ${instance_name}

