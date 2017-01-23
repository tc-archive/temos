#!/bin/bash

# ensure (localhost) target cluster is started


# ensure fleetctl environment is available
export FLEETCTL_TUNNEL=127.0.0.1:2222

# run service
fleetctl start node-alive@{1..3}.service
