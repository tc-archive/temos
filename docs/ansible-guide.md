# ansible

----------------------------------------------------------------------------------------------------

##### configure ansible

```
cat ansible.cfg
[defaults]
hostfile = ~/.ansible/hosts
```


##### configure ansible hosts

```
$> cat  ~/.ansible/hosts
[local]
127.0.0.1
```


##### test aginst localhost

```
ansible all -m ping -u tlangfor --ask-pass
```
