# 数智云平台-PaaS安装（基于数智中台-云图套件）

## 通用配置参数

```bash

COMPONENT="volcano"
helmPackage=volcano-1.6.0.tgz
NAMESPACE="volcano-system"
HOSTS=${HOSTS:=${SSH_HOST}}

```

## 调度管理

````bash
EXECUTED_PERMISSION="suroot"
labelPaasNodes volcano
labelPaasNodes kubestatemetrics
````

## 部署PaaS组件Kafka

[通用argocd部署](deploypaas.md)

#### @由数智云图-自动化云平台构建工具支持