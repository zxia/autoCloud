# 数智云平台-PaaS[Kibana]安装（基于数智中台-云图套件）

## 通用配置参数

```bash
COMPONENT="kibana"
helmPackage=kibana-8.1.0.tgz
NAMESPACE="elk-system"

HOSTS=${HOSTS:=${SSH_HOST}}
```

## 调度管理

```bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH "genEncryptionKey:${NAMESPACE}"
labelPaasNodes ${COMPONENT} ${COMPONENT}
```

## 部署PaaS组件

[通用argocd部署](deploypaas.md)

#### @由数智云图-自动化云平台构建工具支持