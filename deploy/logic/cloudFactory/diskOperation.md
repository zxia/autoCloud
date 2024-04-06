# 数智容器化云平台基础设施建设
---

## 配置数据

````bash
# default HOST 
setConfig k8s
#容器云主机列表
allHost=$(getNodeIpList)
allLiveHost=$(getLiveNodes "${allHost}")
HOSTS=${allLiveHost}
````

## 磁盘分区

1.   #### [磁盘分区](../mop/deploy/diskOperation.md)

#### @由数智云图-自动化云平台构建工具支持