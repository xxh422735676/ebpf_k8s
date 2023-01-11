[参考脚本](https://github.com/lework/kainstall/blob/master/kainstall-ubuntu.sh)
### 帮助信息

```bash
# bash kainstall-centos.sh


Install kubernetes cluster using kubeadm.

Usage:
  kainstall-centos.sh [command]

Available Commands:
  init            Init Kubernetes cluster.
  reset           Reset Kubernetes cluster.
  add             Add nodes to the cluster.
  del             Remove node from the cluster.
  renew-cert      Renew all available certificates.
  upgrade         Upgrading kubeadm clusters.
  update          Update script file.

Flag:
  -m,--master          master node, default: ''
  -w,--worker          work node, default: ''
  -u,--user            ssh user, default: root
  -p,--password        ssh password
     --private-key     ssh private key
  -P,--port            ssh port, default: 22
  -v,--version         kube version, default: latest
  -n,--network         cluster network, choose: [flannel,calico,cilium], default: flannel
  -i,--ingress         ingress controller, choose: [nginx,traefik], default: nginx
  -ui,--ui             cluster web ui, choose: [dashboard,kubesphere], default: dashboard
  -a,--addon           cluster add-ons, choose: [metrics-server,nodelocaldns], default: metrics-server
  -M,--monitor         cluster monitor, choose: [prometheus]
  -l,--log             cluster log, choose: [elasticsearch]
  -s,--storage         cluster storage, choose: [rook,longhorn]
     --cri             cri runtime, choose: [docker,containerd,cri-o], default: docker
     --cri-version     cri version, default: latest
     --cri-endpoint    cri endpoint, default: /var/run/dockershim.sock
  -U,--upgrade-kernel  upgrade kernel
  -of,--offline-file   specify the offline package file to load
      --10years        the certificate period is 10 years.
      --sudo           sudo mode
      --sudo-user      sudo user
      --sudo-password  sudo user password

Example:
  [init cluster]
  kainstall-centos.sh init \
  --master 192.168.77.130,192.168.77.131,192.168.77.132 \
  --worker 192.168.77.133,192.168.77.134,192.168.77.135 \
  --user root \
  --password 123456 \
  --version 1.20.6

  [reset cluster]
  kainstall-centos.sh reset \
  --user root \
  --password 123456

  [add node]
  kainstall-centos.sh add \
  --master 192.168.77.140,192.168.77.141 \
  --worker 192.168.77.143,192.168.77.144 \
  --user root \
  --password 123456 \
  --version 1.20.6

  [del node]
  kainstall-centos.sh del \
  --master 192.168.77.140,192.168.77.141 \
  --worker 192.168.77.143,192.168.77.144 \
  --user root \
  --password 123456
 
  [other]
  kainstall-centos.sh renew-cert --user root --password 123456
  kainstall-centos.sh upgrade --version 1.20.6 --user root --password 123456
  kainstall-centos.sh update
  kainstall-centos.sh add --ingress traefik
  kainstall-centos.sh add --monitor prometheus
  kainstall-centos.sh add --log elasticsearch
  kainstall-centos.sh add --storage rook
  kainstall-centos.sh add --ui dashboard
  kainstall-centos.sh add --addon nodelocaldns
```

### 初始化集群

```bash
# 使用脚本参数
bash kainstall-centos.sh init \
  --master 192.168.77.130,192.168.77.131,192.168.77.132 \
  --worker 192.168.77.133,192.168.77.134 \
  --user root \
  --password 123456 \
  --port 22 \
  --version 1.20.6

# 使用环境变量
export MASTER_NODES="192.168.77.130,192.168.77.131,192.168.77.132"
export WORKER_NODES="192.168.77.133,192.168.77.134"
export SSH_USER="root"
export SSH_PASSWORD="123456"
export SSH_PORT="22"
export KUBE_VERSION="1.20.6"
bash kainstall-centos.sh init
```

> 默认情况下，除了初始化集群外，还会安装 `ingress: nginx` , `ui: dashboard` 两个组件。

还可以使用一键安装方式, 连下载都省略了。

```bash
bash -c "$(curl -sSL https://ghproxy.com/https://raw.githubusercontent.com/lework/kainstall/master/kainstall-centos.sh)"  \
  - init \
  --master 192.168.77.130,192.168.77.131,192.168.77.132 \
  --worker 192.168.77.133,192.168.77.134 \
  --user root \
  --password 123456 \
  --port 22 \
  --version 1.20.6
```

### 增加节点

> 操作需在 k8s master 节点上操作，ssh连接信息非默认时请指定

```bash
# 增加单个master节点
bash kainstall-centos.sh add --master 192.168.77.135

# 增加单个worker节点
bash kainstall-centos.sh add --worker 192.168.77.134

# 同时增加
bash kainstall-centos.sh add --master 192.168.77.135,192.168.77.136 --worker 192.168.77.137,192.168.77.138
```

### 删除节点

> 操作需在 k8s master 节点上操作，ssh连接信息非默认时请指定

```bash
# 删除单个master节点
bash kainstall-centos.sh del --master 192.168.77.135

# 删除单个worker节点
bash kainstall-centos.sh del --worker 192.168.77.134

# 同时删除
bash kainstall-centos.sh del --master 192.168.77.135,192.168.77.136 --worker 192.168.77.137,192.168.77.138
```

### 重置集群

```bash
bash kainstall-centos.sh reset \
  --user root \
  --password 123456 \
  --port 22 \
```

### 其他操作

> 操作需在 k8s master 节点上操作，ssh连接信息非默认时请指定
> **注意：** 添加组件时请保持节点的内存和cpu至少为`2C4G`的空闲。否则会导致节点下线且服务器卡死。

```bash
# 添加 nginx ingress
bash kainstall-centos.sh add --ingress nginx

# 添加 prometheus
bash kainstall-centos.sh add --monitor prometheus

# 添加 elasticsearch
bash kainstall-centos.sh add --log elasticsearch

# 添加 rook
bash kainstall-centos.sh add --storage rook

# 添加 nodelocaldns
bash kainstall-centos.sh add --addon nodelocaldns

# 升级版本
bash kainstall-centos.sh upgrade --version 1.20.6

# 重新颁发证书
bash kainstall-centos.sh renew-cert

# debug模式
DEBUG=1 bash kainstall-centos.sh

# 更新脚本
bash kainstall-centos.sh update

# 使用 cri-o containerd runtime
bash kainstall-centos.sh init \
  --master 192.168.77.130,192.168.77.131,192.168.77.132 \
  --worker 192.168.77.133,192.168.77.134,192.168.77.135 \
  --user root \
  --password 123456 \
  --cri containerd
  
# 使用 cri-o cri runtime
bash kainstall-centos.sh init \
  --master 192.168.77.130,192.168.77.131,192.168.77.132 \
  --worker 192.168.77.133,192.168.77.134,192.168.77.135 \
  --user root \
  --password 123456 \
  --cri cri-o
```

### 默认设置

> **注意:** 以下变量都在脚本文件的`environment configuration`部分。可根据需要自行修改，或者为变量设置同名的**环境变量**修改其默认内容。

```bash
# 版本
KUBE_VERSION="${KUBE_VERSION:-latest}"
FLANNEL_VERSION="${FLANNEL_VERSION:-0.19.0}"
METRICS_SERVER_VERSION="${METRICS_SERVER_VERSION:-0.6.1}"
INGRESS_NGINX="${INGRESS_NGINX:-1.3.0}"
TRAEFIK_VERSION="${TRAEFIK_VERSION:-2.6.1}"
CALICO_VERSION="${CALICO_VERSION:-3.22.4}"
CILIUM_VERSION="${CILIUM_VERSION:-1.9.17}"
KUBE_PROMETHEUS_VERSION="${KUBE_PROMETHEUS_VERSION:-0.11.0}"
ELASTICSEARCH_VERSION="${ELASTICSEARCH_VERSION:-8.3.2}"
ROOK_VERSION="${ROOK_VERSION:-1.9.7}"
LONGHORN_VERSION="${LONGHORN_VERSION:-1.3.0}"
KUBERNETES_DASHBOARD_VERSION="${KUBERNETES_DASHBOARD_VERSION:-2.6.0}"
KUBESPHERE_VERSION="${KUBESPHERE_VERSION:-3.3.0}"

# 集群配置
KUBE_DNSDOMAIN="${KUBE_DNSDOMAIN:-cluster.local}"
KUBE_APISERVER="${KUBE_APISERVER:-apiserver.$KUBE_DNSDOMAIN}"
KUBE_POD_SUBNET="${KUBE_POD_SUBNET:-10.244.0.0/16}"
KUBE_SERVICE_SUBNET="${KUBE_SERVICE_SUBNET:-10.96.0.0/16}"
KUBE_IMAGE_REPO="${KUBE_IMAGE_REPO:-registry.cn-hangzhou.aliyuncs.com/kainstall}"
KUBE_NETWORK="${KUBE_NETWORK:-flannel}"
KUBE_INGRESS="${KUBE_INGRESS:-nginx}"
KUBE_MONITOR="${KUBE_MONITOR:-prometheus}"
KUBE_STORAGE="${KUBE_STORAGE:-rook}"
KUBE_LOG="${KUBE_LOG:-elasticsearch}"
KUBE_UI="${KUBE_UI:-dashboard}"
KUBE_ADDON="${KUBE_ADDON:-metrics-server}"
KUBE_FLANNEL_TYPE="${KUBE_FLANNEL_TYPE:-vxlan}"
KUBE_CRI="${KUBE_CRI:-containerd}"
KUBE_CRI_VERSION="${KUBE_CRI_VERSION:-latest}"
KUBE_CRI_ENDPOINT="${KUBE_CRI_ENDPOINT:-unix:///run/containerd/containerd.sock}"

# 定义的master和worker节点地址，以逗号分隔
MASTER_NODES="${MASTER_NODES:-}"
WORKER_NODES="${WORKER_NODES:-}"

# 定义在哪个节点上进行设置
MGMT_NODE="${MGMT_NODE:-127.0.0.1}"

# 节点的连接信息
SSH_USER="${SSH_USER:-root}"
SSH_PASSWORD="${SSH_PASSWORD:-}"
SSH_PRIVATE_KEY="${SSH_PRIVATE_KEY:-}"
SSH_PORT="${SSH_PORT:-22}"
SUDO_USER="${SUDO_USER:-root}"

# 节点设置
HOSTNAME_PREFIX="${HOSTNAME_PREFIX:-k8s}"

# 脚本设置
GITHUB_PROXY="${GITHUB_PROXY:-https://gh.lework.workers.dev/}"
GCR_PROXY="${GCR_PROXY:-k8sgcr.lework.workers.dev}"
SKIP_UPGRADE_PLAN=${SKIP_UPGRADE_PLAN:-false}
SKIP_SET_OS_REPO=${SKIP_SET_OS_REPO:-false}
```
