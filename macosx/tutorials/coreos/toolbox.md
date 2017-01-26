# toolbox

###### logon coreos node
```
fleetctl list-machines -l
fleetctl ssh ${MACHINE_ID}
```

##### install toolbox and required applications
```
>core@core-01 ~ $ toolbox
[root@core-01 ~]# dnf install nmap
root@core-01 ~]# nmap -p80 google.com
```
