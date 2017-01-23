#!/bin/bash

# log into docker hub
# docker login

# build the image
docker build -t templecloud/node-alive .

# push to docker hub
# docker push templecloud/node-alive

# logout of docker registry
# docker logout

# tag for local registry
docker tag templecloud/node-alive localhost:5000/templecloud/node-alive

# push to local registry
docker push localhost:5000/templecloud/node-alive

