# 数智云平台-PaaS[SeaweedFS]安装（基于数智中台-云图套件）

## 通用配置参数

```bash
COMPONENT="seaweedfs"
helmPackage=seaweedfs-1.1.1.tgz
NAMESPACE="seaweedfs-system"

HOSTS=${HOSTS:=${SSH_HOST}}
```

## 调度管理

```bash
labelPaasNodes "seaweedfsmaster" "seaweedfsmaster"
labelPaasNodes "seaweedfsvolume" "seaweedfsvolume"
labelPaasNodes "seaweedfsfiler" "seaweedfsfiler"
labelPaasNodes "swcsicontroller" "swcsicontroller"
labelPaasNodes "swcsinode" "swcsinode"
```

## 部署PaaS组件

[通用argocd部署](deploypaas.md)

#### @由数智云图-自动化云平台构建工具支持