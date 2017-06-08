# Kubernetes Install via Kubeadm Oracle Bare Metal Cloud

* https://github.com/kristenjacobs/polibot/blob/master/README.md



---

## Install via kubeadm

### Provision OBMCS machines

* manually
* bash scripts + obmcs-cli
* terraform + obmcs-terraform-plugin


---
us-phoenix-1.oraclecloud.com/Content/API/Concepts/apisigningkey.htm)

---

    ##### connect toe kb8s cluster from another machine
    ```
    export kube_master_public_ip=129.146.28.12
    scp -i ~/.ssh/obmc-bristoldev/obmc-bristoldev opc@${kube_master_public_ip}:admin.conf .

    # !!! - replace server with pubic ip address

    # 129.146.28.12 > server: https://10.0.0.41:6443
    export KUBECONFIG=$(pwd)/admin.conf
    kubectl proxy
    ```

    * NB: UI at http://127.0.0.1:8001/ui





```
lsof -n -i | grep LISTEN
lsof -n -iTCP:8001 | grep LISTEN
```
---
