# fleetctl

see: 

----------------------------------------------------------------------------------------------------
##### fleetctl - configure the remote cluster tunnel as an environment variable

```
PRIMARY_INSTANCE=core-01
SSH_PORT=$(vagrant port ${PRIMARY_INSTANCE}| grep '=>' | cut -d' ' -f 8)
export FLEETCTL_TUNNEL=127.0.0.1:$SSH_PORT
```

----------------------------------------------------------------------------------------------------
##### fleetctl - machine cluster commands

```
fleetctl --tunnel=127.0.0.1:2222 list-machines
fleetctl list-machines --full
fleetctl ssh <machine id>
```

----------------------------------------------------------------------------------------------------
##### fleetctl - service unit commands

```
fleetctl list-units
fleetctl submit     <unit file>
fleetctl load       <unit file>
fleetctl start      <unit file>
fleetctl status     <unit file>
fleetctl ssh        <unit file>
fleetctl journal -f <unit file>
fleetctl stop       <unit file>
fleetctl unload     <unit file> 
fleetctl destroy    <unit file>
```

----------------------------------------------------------------------------------------------------
####  service unit file - dockerised nginx example

NB: '='  denotes service deployment should fail if the command fails.
NB: '=-' denotes service deployment should not fail if the command fails.

```
>[Unit]
Description=My Nginx Server
Requires=docker.service
After=docker.service

[Service]
ExecStartPre=-/usr/bin/docker kill nginx
ExecStartPre=-/usr/bin/docker rm nginx
ExecStartPre=/usr/bin/docker pull nginx:latest
ExecStart=/usr/bin/docker run --name mynginx -p 80:80 nginx:latest
```

