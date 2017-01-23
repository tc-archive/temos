# etcdctl guide

see: https://github.com/coreos/etcd/blob/master/etcdctl/READMEv2.md

----------------------------------------------------------------------------------------------------
##### list 

```
etcdctl --endpoints=172.17.8.101:2379 ls -r /
export ETCDCTL_ENDPOINTS=172.17.8.101:2379
etcdctl ls -r /
```

----------------------------------------------------------------------------------------------------
##### make

```
etcdctl mk /foo/new_bar "Hello world"
etcdctl mk --in-order /fooDir "Hello world"
etcdctl mkdir /fooDir
```

----------------------------------------------------------------------------------------------------
##### get

```
etcdctl /coreos.com/networking
etcdctl get /foo/bar
etcdctl -o extended get /foo/bar
```

----------------------------------------------------------------------------------------------------
##### set

```
etcdctl set /foo/bar "Hello world"
etcdctl set /foo/bar "Hello world" --ttl 60
etcdctl set /foo/bar "Goodbye world" --swap-with-value "Hello world"
etcdctl setdir /mydir
```

----------------------------------------------------------------------------------------------------
##### update

```
etcdctl update /foo/bar "Hola mundo"
```

----------------------------------------------------------------------------------------------------
##### delete

```
etcdctl rm /foo/bar
etcdctl rmdir /path/to/dir
etcdctl rm /path/to/dir --recursive
etcdctl rm /foo/bar --with-value "Hello world"
etcdctl rm /foo/bar --with-index 12
```

----------------------------------------------------------------------------------------------------
##### watch 

```
etcdctl watch /foo/bar
etcdctl watch /foo/bar --forever
etcdctl watch /foo/bar --forever --index 12
```

