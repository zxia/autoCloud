# 容器云平台主机管理

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

```bash
CLUSTER_STATE=5GMC_HOST
```
1.   ##### [更新状态](../mop/deploy/updateState.md)


#### @由数智云图-自动化云平台构建工具支持