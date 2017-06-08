account=tim.langford@gmail.com
project=trjl-158912
zone_=europe-west1-c
username=tlangfor
ssh_key=${HOME}/.ssh/google_compute_engine

cluster_name=trjl-gce-k8s-cluster
machine_type=f1-micro
num_nodes=3

gce-k8s-create:
	# https://cloud.google.com/sdk/gcloud/reference/auth/login
	gcloud auth login ${account}
	# https://cloud.google.com/sdk/gcloud/reference/container/clusters/create
	gcloud container clusters create ${cluster_name} --machine-type ${machine_type} --num-nodes ${num_nodes}
	# https://cloud.google.com/sdk/gcloud/reference/container/clusters/get-credentials
	gcloud container clusters get-credentials ${cluster_name}

gce-k8s-destroy:
	# https://cloud.google.com/sdk/gcloud/reference/auth/login
	gcloud auth login ${account}
	# https://cloud.google.com/sdk/gcloud/reference/container/clusters/create
	gcloud container clusters delete ${cluster_name} --async

gce-k8s-describe:
	# https://cloud.google.com/sdk/gcloud/reference/container/clusters/describe
	gcloud container clusters describe trjl-gce-k8s-cluster

gce-k8s-configure-kubectl:
	# https://cloud.google.com/sdk/gcloud/reference/container/clusters/get-credentials
	gcloud container clusters get-credentials ${cluster-name} --project ${project} --zone ${zone}

gce-k8s-proxy:
	kubectl proxy

gce-k8s-get-nodes:
	kubectl get nodes -o wide

gce-k8s-ssh-ip:
	ssh -i ${ssh-key} ${user_name}@${ip_address}

gce-k8s-ssh-instance_name:
	gcloud compute ssh ${instance_name}

