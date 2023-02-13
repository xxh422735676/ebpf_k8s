#!/bin/bash
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#tear-down

function node_clean(){
    local NODE_NAME=$1
    kubectl drain $NODE_NAME --delete-emptydir-data --force --ignore-daemonsets
    kubeadm reset
    iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
    kubectl delete node $NODE_NAME
}

function master_clean(){
    kubeadm reset
}

if [ $#<1 ]
then
    echo 'wrong arg'
    exit
elif [ $1 == 'master' ]
    master_clean
else 
    node_clean $1
fi

