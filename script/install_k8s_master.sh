#!/bin/bash

## Install Container Runtimes https://kubernetes.io/docs/setup/production-environment/container-runtimes/
# //Kubernetes releases before v1.24 included a direct integration with Docker Engine,

mkdir /tmp/kubeinstall -p
pushd /tmp/kubeinstall 

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

#------------------
## Install kubeadm kubectl kubelet
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

mkdir ./kubeadm.config 
cd kubeadm.config
#kubeadm config print init-defaults > new-config.yaml
kubeadm init --skip-phases=addon/kube-proxy --config ./init-config.yaml

kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.2.71 --skip-phases=addon/kube-proxy
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

#集群已经有kube-proxy
kubectl -n kube-system delete ds kube-proxy
# Delete the configmap as well to avoid kube-proxy being reinstalled during a kubeadm upgrade (works only for K8s 1.19 and newer)
kubectl -n kube-system delete cm kube-proxy
# Run on each node with root permissions:
iptables-save | grep -v KUBE | iptables-restore


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



helm install cilium cilium/cilium    --namespace kube-system    --set hubble.relay.enabled=true     --set hubble.ui.enabled=true    --set prometheus.enabled=true    --set operator.prometheus.enabled=true    --set hubble.enabled=true    --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}"


kubeadm join 192.168.2.71:6443 --token hm4dp0.lopnffb8tjfbie26 \
	--discovery-token-ca-cert-hash sha256:4724f347873002f0e878cead8cb11603663a1a4ffbc82609535a53d591dbb077 
# get token 
kubeadm token create
# get sha256
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'


    export KUBECONFIG=/etc/kubernetes/admin.conf

[dev@centos9 ~]$ kubectl create -f https://raw.githubusercontent.com/cilium/cilium/v1.9/install/kubernetes/quick-install.yaml

helm template cilium cilium/cilium  \
    --namespace kube-system \
    --set kubeProxyReplacement=strict \
    --set k8sServiceHost=apiserver.foxchan.com \
    --set k8sServicePort=6443 > cilium.yaml
sed -i "s/replicas: 2/replicas 1/g" cilium.yaml
kubectl apply -f cilium.yaml

ip a | awk  '/192/ {print $2}' | sed 's%/24%%g'