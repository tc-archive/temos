#!/bin/bash

docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock -v `pwd`:/data eclipse/che start
