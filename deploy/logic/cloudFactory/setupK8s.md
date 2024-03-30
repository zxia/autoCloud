# 容器云平台构建

## 0. 对于新机器，进行一些初始化安装
###配置变量
```bash
setConfig k8s
#容器云主机列表
allHost=$(getNodeIpList)
allLiveHost=$(getLiveNodes "${allHost}")

HOSTS=$(getLiveNodes "${allHost}")
RPM_PACKAGE_NAME="rsync-3.1.2-12.el7_9.x86_64.rpm"
```

###执行任务
1. ### [创建用户](../mop/deploy/createUser.md)
2. ### [部署rsync](../mop/deploy/installRpm.md)

## 1. 获取集群拓扑

````bash

#容器云控制结点列表
allMasterHost=$(getNodeIpListByType master)
#获取已经安装的主机列表
readyHost=$(getHostReadyHostIpList)
#获取已经安装的k8S结点列表
executeExpect Bash  "rm -rf /root/.ssh/known_hosts"
#清理known_hosts缓存
````
### 2. 获取容器云拓扑
````bash
HOSTS=$(getLiveNodes "${controlPlaneEndpointIP}")
````

#### [获取容器云拓扑](../mop/deploy/getK8sInfo.md)

````bash
#容器云控制主结点
initHost=${controlPlaneEndpointIP}
#容器云除主结点外其它结点
joinHost=$(complementSet allHost initHost)
#容器云已经安装的结点
k8sReadyHost=$(getK8sReadyIpList)
````

## 安装主机

### 1. 需要安装的主机列表

````bash
#需要安装的主机列表为容器云主机总数-已经安装的主机列表
HOSTS=$(getLiveNodes "$(complementSet allHost readyHost)")
````

### 2. 每一个主机，需要安装和配置

1.   #### [安装基础设施](../mop/deploy/prepareHostInstall.md)
1.   #### [主机配置](../mop/deploy/configHost.md)
1.   #### [配置时间同步](../mop/deploy/setupChrony.md)

### 3. 每一个主机，需要准备Kubernetes安装工作

1.   #### [kubernetes安装准备工作-采用kubeadm进行安装](../mop/deploy/prepareK8s.md)
1.   #### 容器运行环境安装

-  ##### [安装containerd](../mop/deploy/installContainerd.md)
```bash
CLUSTER_STATE=5GMC_HOST
```
1.   ##### [更新状态](../mop/deploy/updateState.md)
## 安装Kubernetes主结点

### 1. 主结点选取

````bash
HOSTS=$(getLiveNodes "$(complementSet initHost k8sReadyHost)")
````

1. #### [安装主控制结点](../mop/deploy/initK8s.md)

### 2. 安装TopoLVM插件，支持动态本地存储
1. #### 配置TopoLVM
1. #### [TopoLVM安装](../mop/paas/topolvm.md)


## 创建Kubernetes集群

### 1. 根据结点类型，加入到Kubernetes集群中

````bash
#添加的K8s结点=期望增加的非主点-已经安装过的结点
HOSTS=$(getLiveNodes "$(complementSet joinHost k8sReadyHost)")
````

- #### [准备创建](../mop/deploy/prepareJoinK8s.md)
- #### [创建Kubernets集群](../mop/deploy/joinK8s.md)

### 2. 对于控制结点，需要进行后处理

````bash
HOSTS=$(getLiveNodes "$(complementSet allMasterHost k8sReadyHost)")

````

- #### [配置支持TopoLVM](../mop/paas/topolvmjoin.md)


#### @由数智云图-自动化云平台构建工具支持