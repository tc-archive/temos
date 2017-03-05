#!/bin/bash


https://github.com/GoogleCloudPlatform/spinnaker-deploymentmanager.git

gcloud deployment-manager deployments create --config config.jinja [DEPLOYMENT_NAME] --properties jenkinsPassword=[YOUR_PASSWORD]

gcloud compute instances list | grep spinnaker

gcloud compute ssh [DEPLOYMENT_NAME]-spinnaker-ogo8 --zone us-west1-a -- -L 9000:localhost:9000 -L8084:localhost:8084
gcloud compute ssh archer-jenkins-7w9l --zone us-west1-a -- -L 9999:localhost:8080


gcloud deployment-manager deployments delete [DEPLOYMENT_NAME]

open http://localhost:9000


---

# NAME                         TYPE                               STATE      ERRORS  INTENT
# archer-jenkins-hc            compute.v1.httpHealthCheck         COMPLETED  []
# archer-jenkins-ig            compute.beta.instanceGroupManager  COMPLETED  []
# archer-jenkins-template      compute.v1.instanceTemplate        COMPLETED  []
# archer-redis-ig              compute.v1.instanceGroupManager    COMPLETED  []
# archer-redis-template        compute.v1.instanceTemplate        COMPLETED  []
# archer-spinnaker-bucket      storage.v1.bucket                  COMPLETED  []
# archer-spinnaker-hc          compute.v1.httpHealthCheck         COMPLETED  []
# archer-spinnaker-ig          compute.beta.instanceGroupManager  COMPLETED  []
# archer-spinnaker-network     compute.v1.network                 COMPLETED  []
# archer-spinnaker-subnetwork  compute.v1.subnetwork              COMPLETED  []
# archer-spinnaker-template    compute.v1.instanceTemplate        COMPLETED  []
# jenkins-fw                   compute.v1.firewall                COMPLETED  []
# jenkins-hc                   compute.v1.firewall                COMPLETED  []
# redis-fw                     compute.v1.firewall                COMPLETED  []
# spinanker-hc                 compute.v1.firewall                COMPLETED  []
# spinnaker-vm-ssh-fw          compute.v1.firewall                COMPLETED  []

gcloud deployment-manager deployments delete archer
gcloud deployment-manager deployments create --config config.jinja archer --properties jenkinsPassword:woodhouse
gcloud compute instances list | grep spinnaker
# NB:  ssh reversel tunnel: (exposedLocalPort : tunneledRemoteUrlPort)
spinnaker_host=$(gcloud compute instances list | grep spinnaker | awk {'print $1'})
gcloud compute ssh ${spinnaker_host} --zone us-west1-a -- -L 9000:localhost:9000 -L 8084:localhost:8084 -L 8087:localhost:8087
jenkins_host=$(gcloud compute instances list | grep jenkins | awk {'print $1'})
gcloud compute ssh ${jenkins_host} --zone us-west1-a -- -L 8080:localhost:8080 -L 9999:localhost:9999
redis_host=$(gcloud compute instances list | grep redis | awk {'print $1'})
gcloud compute ssh ${redis_host} --zone us-west1-a
hello_host=$(gcloud compute instances list | grep hello | awk {'print $1'})
gcloud compute ssh ${hello_host} --zone us-west1-a -- -L 8081:localhost:8080
###### update jenkins machine
```
1) Install git plugin via UI
2) Create two spinnaker jobs: 
	1) Poller
	2) Builder
3) Install Aptly
	1) Install
	2) Ensure 9999 is open
4) Install java jdk - sudo apt-get install default-jdk && sudo apt-get install jenkins git
```

# curl http://localhost:9999/dists/trusty/main/binary-amd64/Packages
# curl http://archer-jenkins-xlh7:9999/dists/trusty/main/binary-amd64/Packages

cd /var/log/spinnaker/
cd /opt/spinnaker/

###### update spinnaker machine
# spinnaker - start all the spinnaker services
alias spinnaker_status="initctl list | grep -E 'front50|rosco|clouddriver|gate|orca|igor|echo|fiat'"
MS=(front50 rosco clouddriver gate orca igor echo fiat)
for s in "${MS[@]}"; do sudo service ${s} start; done
for s in "${MS[@]}"; do sudo service ${s} restart; done 
```
1) Update /opt/spinnaker/config/spinnaker-local.yml 
	1) 'jenkins' section with jenkins url, username, and password
	2) 'igor' section with enabled = true
2) Update /opt/spinnaker/config/rosco.yml or vim /opt/rosco/config/rosco.yml
	1) debianRepository with the deb repo
	2) bakeOptions change to 'us-west1' 'archer-spinnaker-network' 'archer-spinnaker-subnetwork'
```

curl http://archer-jenkins-cvqs:80 | head -n 20

eval `redis-cli -h archer-redis-mqz4 hget 8c87f742-a595-4446-83be-66d6cd72a730 command | sed 's/\\"/"/g'`

sudo service jenkins restart && sudo service nginx restart
