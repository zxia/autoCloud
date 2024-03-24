# 数智容器化云平台构建
---

## 准备配置数据

###获取主机拓扑

````bash
setConfig k8s
#容器云主机列表
allHost=$(getNodeIpList)
#容器云控制结点列表
allMasterHost=$(getNodeIpListByType master)
#获取已经安装的主机列表
readyHost=$(getHostReadyHostIpList)
#获取已经安装的k8S结点列表
````

### [获取容器云拓扑](../mop/deploy/getK8sInfo.md)

````bash
#容器云控制主结点
initHost=${controlPlaneEndpointIP}
#容器云除主结点外其它结点
joinHost=$(complementSet allHost initHost)
#容器云已经安装的结点
k8sReadyHost=$(getK8sReadyIpList)
````

## 安装主机

###需要安装的主机列表

````bash
#需要安装的主机列表为容器云主机总数-已经安装的主机列表
HOSTS=$(complementSet allHost readyHost)
````

### 对每一个主机，需要安装和配置

1.   ### [创建用户](../mop/deploy/createUser.md)
1.   ### [安装基础设施](../mop/deploy/prepareHostInstall.md)
1.   ### [更新内核](../mop/deploy/updateKernal.md)
1.   ### [主机配置](../mop/deploy/configHost.md)

### Kubernetes准备工作

1.   ### [kubernetes安装准备工作-采用kubeadm进行安装](../mop/deploy/prepareK8s.md)
1.   ### 容器运行环境安装

-  #### [安装containerd](../mop/deploy/installContainerd.md)

## 安装Kubernetes主结点

- ### 目标主机

````bash
HOSTS=$(complementSet initHost k8sReadyHost)
````

- ### [安装主控制结点](../mop/deploy/initK8s.md)

- ### 安装TopoLVM插件，支持动态本地存储
    * 配置TopoLVM
    * [TopoLVM安装](../mop/paas/topolvm.md)

## 创建Kubernetes集群

### 根据结点类型，加入到Kubernetes集群中

````bash
HOSTS=$(complementSet joinHost k8sReadyHost)
````

- ### [准备创建](../mop/deploy/prepareJoinK8s.md)
- ### [创建Kubernets集群](../mop/deploy/joinK8s.md)

###对于控制结点，需要进行后处理

````bash
HOSTS=$(complementSet allMasterHost k8sReadyHost)
````

- ### [配置支持TopoLVM](../mop/paas/topolvmjoin.md)

````bash
unsetConfig k8s
````

#### @由数智云图-自动化云平台构建工具支持