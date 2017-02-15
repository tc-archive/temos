#!/bin/bash

# docker
#
alias docker-clean='unset ${!DOCKER_*}'
alias moby='screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty'

# docker machine
#
# alias docker-init-default='eval "$(docker-machine env default)"'
# alias docker-init-local='eval "$(docker-machine env local)"'
# alias create-default="docker-machine create --driver virtualbox default"
# alias kitematic="open '/Applications/Docker/Kitematic (Beta).app'"
