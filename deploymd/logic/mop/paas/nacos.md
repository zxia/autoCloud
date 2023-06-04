# 数智云平台-PaaS[Nacos]安装（基于数智中台-云图套件）

## 检查是否已经安装 mysql/mariadb

```bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH "checkMariadb:mariadb-system"
```

## 初始化数据库

> 1. kubectl cp ${cnfRoot}/k8s/devops/data/nacos-mysql.sql mariadb-primary-0:bitnami/mariadb/ -n mariadb-system -c
     mariadb
> 2. kubectl exec -it mariadb-primary-0 -n mariadb-system bash
> 3. mysql -uroot -pOkPig965cX
> 4. source /bitnami/mariadb/nacos-mysql.sql

## 通用配置参数

```bash
COMPONENT="nacos"
helmPackage=nacos-0.1.5.tgz
NAMESPACE="nacos-system"

HOSTS=${HOSTS:=${SSH_HOST}}
```

## 调度管理

```bash
labelPaasNodes ${COMPONENT} ${COMPONENT}
```

## 部署PaaS组件

[通用argocd部署](deploypaas.md)

#### @由数智云图-自动化云平台构建工具支持

