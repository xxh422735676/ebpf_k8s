#!/bin/bash
###################################################################
#Script Name    : install_k8s_master.sh
#Description    : Install kubernetes cluster && cilium.
#Author         : xxh422735676
#Email          : 422735676@qq.com
###################################################################

# set -x
set -e

set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline

## CONFIGURATIONS ##

APISERVER_IP=$(ip a | awk  '/192/ {print $2}' | sed 's%/24%%g')
MASTER_TOKEN=''
MASTER_DISCRET=''

source ./include.sh

mkdir /tmp/kubeinstall -p
pushd /tmp/kubeinstall 
log::info "Script Name    : $(pwd)/install_k8s_master.sh"
sleep 2
## Install Container Runtimes https://kubernetes.io/docs/setup/production-environment/container-runtimes/
# //Kubernetes releases before v1.24 included a direct integration with Docker Engine,


### Forwarding IPv4 and letting iptables see bridged traffic

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf 
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
lsmod | grep br_netfilter
lsmod | grep overlay
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

## Configure Cgroup drivers (https://www.techrepublic.com/article/install-containerd-ubuntu/)
### Containerd

wget https://github.com/containerd/containerd/releases/download/v1.6.16/containerd-1.6.16-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-1.6.16-linux-amd64.tar.gz

### runc
wget https://github.com/opencontainers/runc/releases/download/v1.1.4/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc

### CNI
sudo mkdir -p /opt/cni/bin
wget https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-amd64-v1.2.0.tgz
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.2.0.tgz

### configure Containerd
sudo mkdir /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo curl -L https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /etc/systemd/system/containerd.service
sudo systemctl restart containerd
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
sudo systemctl status containerd | grep running

log::info 'containerd installation finished'
#------------------
## Install kubeadm kubectl kubelet
log::info 'installing kubernetes without kube/proxy'
sudo apt update
sudo apt-get install -y apt-transport-https ca-certificates curl

#Add the Kubernetes apt repository:
sudo mkdir /etc/apt/keyrings -p
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

#install kubelet, kubeadm and kubectl, and pin their version:
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


sudo swapoff -a

kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$APISERVER_IP --skip-phases=addon/kube-proxy

export KUBECONFIG=/etc/kubernetes/admin.conf
echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> ~/.profile

log::info 'kubernetes installation compeleted'
# get token 
MASTER_TOKEN=$(kubeadm token create)

# get sha256
MASTER_DISCRET=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')

log::info "you can join nodes with command run on node machine: kubeadm join 192.168.2.71:6443 --token $MASTER_TOKEN	--discovery-token-ca-cert-hash sha256:$MASTER_DISCRET"

kubectl taint nodes --all node-role.kubernetes.io/control-plane-
log::info 'node isolation on master disabled'

log::info 'installing cilium'

# helm && cilium

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
./get_helm.sh

helm repo add cilium https://helm.cilium.io

#cilium cli 

CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/master/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}


helm template cilium cilium/cilium  \
    --namespace kube-system \
    --set kubeProxyReplacement=strict \
    --set k8sServiceHost=$APISERVER_IP \
    --set k8sServicePort=6443 > cilium.yaml
log::info 'using one operator coz of anti-affinity'
sed -i "s/replicas: 2/replicas: 1/g" cilium.yaml

kubectl apply -f cilium.yaml

log::info 'installation compeletd!'

popd

log::info 'checking all status'
sleep 5

cilium status --wait
kubectl get nodes
kubectl get pods -n kube-system

log::info "please run 'source ~/.profile' to start using kubernetes"
