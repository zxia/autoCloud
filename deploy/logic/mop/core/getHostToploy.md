# 数智容器化云平台构建

## 获取主机拓扑

| 全局变量 | 描述 | 
|-------------|-------------|
|allHost | 集群所有主机内网IP列表 |
|readyHost| 已经安装基础组件的主机IP列表|
|allMasterHost|期望安装的容器云控制结点列表|
|readyMasterHost|已经运行容器云控制结点列表|
|allWorkHost|期望安装的容器云工作结点列表|
|readyWorkerHost|已经运行容器云工作结点列表|
|addHost| 需要增加主机结点列表 allHost-readyHost|
|delMasterHost| 需要删除的控制结点列表 readyMasterHost-allMasterHost|
|delWorkerHost| 需要删除的工作结点列表 readyWorkerHost-allWorkHost|
|addMasterHost| 需要增加的控制结点列表 allMasterHost-readyMasterHost|
|addWorkerHost| 需要增加的工作结点列表 allWorkHost-readyWorkerHost|
|initHost| 初始化集群的控制结点 controlPlaneEndpointIP-readyMasterHost|

````bash
setConfig k8s
#容器云主机列表
allHost=$(getNodeIpList)
#容器云控制结点列表
allMasterHost=$(getNodeIpListByType master)
#容器云控制结点列表
allWorkerHost=$(getNodeIpListByType worker)
#获取已经安装的主机列表
readyHost=$(getHostReadyHostIpList)
#获取已经安装的k8S结点列表
````

### [获取容器云拓扑](../mop/deploy/getK8sInfo.md)

````bash
#容器云已经安装的结点
readyMasterHost=$(getK8sReadyIpListByType control-plane)
readyK8sMaster=$(getK8sReadyIpList)
readyWorkerHost=$(complementSet readyK8sMaster readyMasterHost)
delMasterHost=$(complementSet readyMasterHost allMasterHost)
delWorkerHost=$(complementSet readyWorkerHost allWorkerHost)
addMasterHost=$(complementSet allMasterHost readyMasterHost)
addWorkerHost=$(complementSet allWorkerHost readyWorkerHost)
````

````bash
unsetConfig k8s
````

#### @由数智云图-自动化云平台构建工具支持