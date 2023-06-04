# 数智云平台-PaaS安装（基于数智中台-云图套件）

## 通用配置参数

```bash
COMPONENT="redis-cluster"
helmPackage=redis-cluster-8.1.2.tgz
NAMESPACE="redis-cluster-system"
HOSTS=${HOSTS:=${SSH_HOST}}
```

## 调度管理

````bash
labelPaasNodes redis-cluster
````

## 部署PaaS组件

[通用argocd部署](deploypaas.md)

#### @由数智云图-自动化云平台构建工具支持