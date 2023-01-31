#!/bin/bash
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


swapoff -a

mkdir ./kubeadm.config 
cd kubeadm.config
kubeadm config print init-defaults > new-config.yaml
kubeadm init --config new-config.yaml