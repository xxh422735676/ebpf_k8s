# ebpf_k8s

This document is about to illustrate the purpose, project organization and progress.

## Purpose

The method of eBPF non-intrusive injection into the Linux kernel is adopted, and the service registry and front-end and back-end management program for statistical observation data are designed externally to achieve the observability of Kubernetes. At the same time, based on the feature that eBPF can modify data traffic packets and forward socket traffic, it realizes the acceleration of network traffic such as Nginx Ingress in Kubernetes.

The project has three subsystems: data monitoring, visualization and load balancing. Among them, the data monitoring system includes the observation, statistics and acceleration functions of the Kubernetes network traffic of a single machine. The visualization system includes the monitoring of the cluster status, the monitoring status of the upper and lower limit specific hosts, and the visualization output function. The load balancing system includes the acceleration of the memory database, the load balancing of the traffic and the gateway function.

The cluster is set up in the same subnet.

## Project Organization

### K8s

Store kubernetes' runtime scripts and configuration files.

### Gui

Store the source code, and configuration parameter files related to the visualization system

### eBPF

Store the source code related to ebpf, including kubernetes network traffic monitoring and data statistics, kernel xdp acceleration, memory database acceleration, traffic load balancing and other functions.

### script

Store shell scripts to setup eBPF and kubernetes environments.

## Project progress

### Kubernetes

|     Assignments       | Progress |
| ------------------------- | ---- |
| kubernetes' initialization scripts |      |



### Visualization

| Assignments               | Progress |
| ------------------ | ---- |
| Front-end data visualization output |      |
| Back-end business logic processing   |      |
| Deployment script           |      |

### ebpf

| Assignments              | Progress |
| ----------------- | ---- |
| Network traffic RX/TX monitoring |      |
| Internal flow monitoring of container  |      |
| Load balancing         |      |
| Data statistics          |      |
| Deployment script          |      |





## 目的

采用eBPF无侵入式注入Linux内核的方式，并且外部设计了用于统计观测数据的服务注册中心和前后端管理程序，实现了对Kubernetes的可观测性。同时基于eBPF可以修改数据流量包，转发套接字流量的特性，实现了在Kubernetes内部对Nginx Ingress等网络通信流量的加速。

本项目有三个子系统：数据监视，可视化以及负载均衡。其中数据监视系统包含了对单机的kubernetes网络流量的观测，统计以及加速功能。可视化系统包含了对集群状态的监视，上下限特定主机的监视状态，以及可视化输出的功能。负载均衡系统包含了对内存型数据库的加速，流量的负载均衡以及网关功能。

集群在同一子网中架设。

## 组织架构

### k8s

存放kubernetes相关初始化的脚本，配置参数文件等

### gui

存放可视化系统相关的源代码，构建脚本以及配置参数文件等

### ebpf

存放ebpf相关的源代码，包括kubernetes网络流量的监控以及数据统计，内核xdp加速，对内存型数据库的加速，流量的负载均衡等功能，以及相关初始化脚本。

## 项目进度

### kubernetes

| 事项                      | 进度 |
| ------------------------- | ---- |
| kubernetes初始化shell脚本 |      |



### 可视化

| 事项               | 进度 |
| ------------------ | ---- |
| 前端数据可视化输出 |      |
| 后端业务逻辑处理   |      |
| 部署脚本           |      |

### ebpf

| 事项              | 进度 |
| ----------------- | ---- |
| 网络流量RX/TX监控 |      |
| 容器内部流量监控  |      |
| 负载均衡          |      |
| 数据统计          |      |
| 部署脚本          |      |

