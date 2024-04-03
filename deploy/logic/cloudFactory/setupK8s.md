# 容器云平台构建

## 1. 新机器初始化
###配置变量
```bash
setConfig k8s
#容器云主机列表
allHost=$(getNodeIpList)
allLiveHost=$(getLiveNodes "${allHost}")
freshLiveHosts=$(getFreshNodes "${allLiveHost}")
#对于新的节点需要进行一些初始化设置，才能正确访问
HOSTS=${freshLiveHosts}
RPM_PACKAGE_NAME="rsync-3.1.2-12.el7_9.x86_64.rpm"
```

###执行任务
1. ### [创建用户](../mop/deploy/createUser.md)
2. ### [部署rsync](../mop/deploy/installRpm.md)

## 2. 安装主机

### 2.1 需要安装的主机列表

```bash
#需要安装的主机列表为状态不为5GMC_HOST and 5GMC_K8S的节点
HOSTS=$(getHostNotReadyHostIpList "${allLiveHost}")
```

### 2.2 每一个主机，需要安装和配置

1.   #### [安装基础设施](../mop/deploy/prepareHostInstall.md)
1.   #### [主机配置](../mop/deploy/configHost.md)
1.   #### [配置时间同步](../mop/deploy/setupChrony.md)
1.   #### [升级内核](../mop/deploy/updateKernal.md)
### 2.3 每一个主机，需要准备Kubernetes安装工作

1.   #### [kubernetes安装准备工作-采用kubeadm进行安装](../mop/deploy/prepareK8s.md)
1.   #### 容器运行环境安装

-  ##### [安装containerd](../mop/deploy/installContainerd.md)
### 2.4 更新主机状态
```bash
CLUSTER_STATE=5GMC_HOST
```
1.   ##### [更新状态](../mop/deploy/updateState.md)


## 3. 安装或者更新Kubernetes集群

### 3.1 判断主访问节点是否具备条件

```bash
#容器云控制主结点
initHost=${controlPlaneEndpointIP}
#如果主控节点不可访问，退出
ping -c 3  ${initHost} >/dev/null 2>&1 || return $?
#如果主控节点状态不是5GMC_HOST或者5GMC_K8S, 退出
isInitHostReady "${initHost}" || return $?
#如果主控节点状态为5GMC_HOST, 进行安装，否则跳过安装
HOSTS=$(getInitK8sNodeIP "${initHost}")
CLUSTER_STATE=5GMC_K8S
```
### 3.2 进行主控节点安装

1. #### [安装主控制结点](../mop/deploy/initK8s.md)

### 2. 安装TopoLVM插件，支持动态本地存储
1. #### 配置TopoLVM 临时跳过
1. #### [TopoLVM安装]####(../mop/paas/topolvm.md)
1. ##### [更新状态](../mop/deploy/updateState.md)

### 3.3获取在线容器云拓扑
```bash
HOSTS=${controlPlaneEndpointIP}
```
#### [获取容器云拓扑](../mop/deploy/getK8sInfo.md)

### 3.4 准备工作，加入其它节点
- #### [准备创建](../mop/deploy/prepareJoinK8s.md)

### 3.5 计算需要安装的K8s节点
```bash
k8sReadyHost=$(getK8sReadyIpList)
joinHost=$(complementSet  allLiveHost k8sReadyHost)
#添加的K8s结点=期望增加的非主点-已经安装过的结点
HOSTS=$(complementSet joinHost initHost)
```
### 3.6 安装其它节点

- #### [创建Kubernets集群](../mop/deploy/joinK8s.md)
- ##### [更新状态](../mop/deploy/updateState.md)

### 2. 对于控制结点，需要进行后处理

````bash
#容器云控制结点列表
allMasterHost=$(getNodeIpListByType master)
HOSTS=$(getLiveNodes "$(complementSet allMasterHost ${initHost})")
````

- #### [配置支持TopoLVM]###(../mop/paas/topolvmjoin.md)


#### @由数智云图-自动化云平台构建工具支持